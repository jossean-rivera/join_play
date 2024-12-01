import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:join_play/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:join_play/models/sport_event.dart';
import 'package:join_play/navigation/route_names.dart';
import '../utilities/firebase_service.dart';
import 'package:join_play/models/sport_user.dart';

class SportDetailsPage extends StatefulWidget {
  final String sportId;
  final FirebaseService firebaseService;
  final AuthenticationBloc authenticationBloc;

  const SportDetailsPage({
    super.key,
    required this.sportId,
    required this.firebaseService,
    required this.authenticationBloc,
  });

  @override
  _SportDetailsPageState createState() => _SportDetailsPageState();
}

class _SportDetailsPageState extends State<SportDetailsPage> {
  bool showUnavailable = false; // Toggle for available/unavailable events

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details for ${widget.sportId}"),
        actions: [
          Switch(
            value: showUnavailable,
            onChanged: (value) {
              setState(() {
                showUnavailable = value;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                showUnavailable ? "Unavailable" : "Available",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<SportEvent>>(
        future: widget.firebaseService.getEventsForSport(widget.sportId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text("No events available for this sport."));
          } else {
            final events = snapshot.data!.where((event) {
              final hasSlots = (event.slotsAvailable ?? 0) > 0;
              return showUnavailable ? !hasSlots : hasSlots;
            }).toList();

            if (events.isEmpty) {
              return const Center(child: Text("No matching events found."));
            }

            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];

                // Get current user ID
                final currentUserId =
                    widget.authenticationBloc.sportUser?.uuid ?? '';

                // Check if the user is registered for this event
                final isRegistered =
                    event.registeredUsers?.contains(currentUserId) ?? false;

                return FutureBuilder<String>(
                  future: widget.firebaseService.getHostName(event.hostUserId!),
                  builder: (context, hostSnapshot) {
                    final hostName = hostSnapshot.connectionState ==
                            ConnectionState.done
                        ? hostSnapshot.data ?? "Unknown"
                        : "Loading...";

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(event.name ?? ''),
                        subtitle: Text(
                          "Location: ${event.location}\n"
                          "Time: ${event.dateTime?.toDate()}\n"
                          "Slots Available: ${event.slotsAvailable}\n"
                          "Host: $hostName",
                        ),
                        isThreeLine: true,
                        trailing: ElevatedButton(
                          onPressed: () async {
                            if (isRegistered) {
                              // Unregister user
                              await widget.firebaseService
                                  .unregisterFromEvent(event.id!, currentUserId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Unregistered from ${event.name}")),
                              );
                            } else {
                              // Register user
                              await widget.firebaseService
                                  .registerForEvent(event.id!, currentUserId);
                              GoRouter.of(context).goNamed(
                                RouteNames.registrationConfirmation,
                                pathParameters: {'sportId': event.sportId!},
                              );
                            }

                            // Refresh the UI
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isRegistered ? Colors.red : Colors.blue,
                          ),
                          child: Text(isRegistered ? "Unregister" : "Register"),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
