import 'package:flutter/material.dart';
import 'package:join_play/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:join_play/models/sport_event.dart';
import 'package:join_play/navigation/router.dart';
import 'package:join_play/utilities/firebase_service.dart';
import 'package:join_play/navigation/route_names.dart';
import 'package:go_router/go_router.dart';

class MyGamesPage extends StatefulWidget {
  final FirebaseService firebaseService;
  final AuthenticationBloc authenticationBloc;

  const MyGamesPage({
    super.key,
    required this.firebaseService,
    required this.authenticationBloc,
  });

  @override
  State<MyGamesPage> createState() => _MyGamesPageState();
}

class _MyGamesPageState extends State<MyGamesPage> {
  bool showHostedEvents = false; // Toggle between registered and hosted events

  void _navigateToEditForm(BuildContext context, SportEvent event) {
    context.goNamed(
      RouteNames.gameForm,
      pathParameters: {'sportId':event.sportId!},
      extra: event,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = widget.authenticationBloc.sportUser?.uuid ?? '';

    return Column(
      children: [
        // Toggle for Registered vs Hosted Events
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Registered Events"),
              Switch(
                value: showHostedEvents,
                onChanged: (value) {
                  setState(() {
                    showHostedEvents = value;
                  });
                },
              ),
              const Text("Hosted Events"),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<SportEvent>>(
            future: showHostedEvents
                ? widget.firebaseService.getHostedEvents(userId) // Hosted events
                : widget.firebaseService.getUserRegisteredEvents(userId, true), // Registered events
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    showHostedEvents
                        ? "No hosted events found."
                        : "No registered events found.",
                  ),
                );
              } else {
                final events = snapshot.data!;
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return FutureBuilder<List<String>>(
                      future: widget.firebaseService.getUserNames(
                          event.registeredUsers ?? []), // Fetch user names
                      builder: (context, usersSnapshot) {
                        String registeredNames = "Loading...";
                        if (usersSnapshot.connectionState ==
                            ConnectionState.done) {
                          registeredNames = usersSnapshot.hasData
                              ? usersSnapshot.data!.join(", ")
                              : "No registered users";
                        }

                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(event.name ?? 'Unknown Event'),
                            subtitle: Text(
                              "Location: ${event.location}\n"
                              "Time: ${event.dateTime?.toDate()}\n"
                              "Slots Available: ${event.slotsAvailable}\n"
                              "Registered Users: $registeredNames",
                            ),
                            trailing: showHostedEvents
                                ? ElevatedButton(
                                    onPressed: () {
                                      _navigateToEditForm(context, event);
                                      // Placeholder for future edit functionality
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "Host options for ${event.name}"),
                                        ),
                                      );
                                    },
                                    child: const Text("Edit Event"),
                                  )
                                : ElevatedButton(
                                    onPressed: () async {
                                      await widget.firebaseService
                                          .unregisterFromEvent(
                                        event.id!,
                                        userId,
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "Unregistered from ${event.name}"),
                                        ),
                                      );

                                      // Refresh the UI
                                      setState(() {});
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text("Unregister"),
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
        ),
      ],
    );
  }
}
