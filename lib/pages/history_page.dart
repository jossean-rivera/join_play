import 'package:flutter/material.dart';
import 'package:join_play/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:join_play/models/sport_event.dart';
import 'package:join_play/utilities/firebase_service.dart';

class HistoryPage extends StatefulWidget {
  final FirebaseService firebaseService;
  final AuthenticationBloc authenticationBloc;

  const HistoryPage({
    super.key,
    required this.firebaseService,
    required this.authenticationBloc,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    final userId = widget.authenticationBloc.sportUser?.uuid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Past Events"),
      ),
      body: FutureBuilder<List<SportEvent>>(
        future: widget.firebaseService.getUserPastEvents(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No past events found."));
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
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
