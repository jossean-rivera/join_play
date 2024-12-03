import 'package:flutter/material.dart';
import 'package:join_play/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:join_play/models/sport_event.dart';
import 'package:join_play/utilities/firebase_service.dart';

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
  @override
  Widget build(BuildContext context) {
    final userId = widget.authenticationBloc.sportUser?.uuid ?? '';

    return FutureBuilder<List<SportEvent>>(
      future: widget.firebaseService.getUserRegisteredEvents(userId, true), // Fetch future events
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No upcoming events found."));
        } else {
          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(event.name ?? ''),
                  subtitle: Text(
                    "Location: ${event.location}\n"
                    "Time: ${event.dateTime?.toDate()}\n"
                    "Slots Available: ${event.slotsAvailable}",
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await widget.firebaseService.unregisterFromEvent(
                        event.id!,
                        userId,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Unregistered from ${event.name}")),
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
        }
      },
    );
  }
}
