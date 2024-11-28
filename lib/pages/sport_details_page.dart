import 'package:flutter/material.dart';
import '../utilities/firebase_service.dart';

class SportDetailsPage extends StatefulWidget {
  final String sportId;

  const SportDetailsPage({super.key, required this.sportId});

  @override
  _SportDetailsPageState createState() => _SportDetailsPageState();
}

class _SportDetailsPageState extends State<SportDetailsPage> {
  final FirebaseService firebaseService = FirebaseService();
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: firebaseService.getEventsForSport(widget.sportId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No events available for this sport."));
          } else {
            final events = snapshot.data!
                .where((event) {
                  final hasSlots = event['slotsAvailable'] > 0;
                  return showUnavailable ? !hasSlots : hasSlots;
                })
                .toList();

            if (events.isEmpty) {
              return const Center(child: Text("No matching events found."));
            }

            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(event['name']),
                    subtitle: Text(
                      "Location: ${event['location']}\n"
                      "Time: ${event['dateTime'].toDate()}\n"
                      "Slots Available: ${event['slotsAvailable']}",
                    ),
                    isThreeLine: true,
                    trailing: event['slotsAvailable'] > 0
                        ? ElevatedButton(
                            onPressed: () async {
                              await firebaseService.registerForEvent(
                                event['id'], // Event ID
                                "testUserId", // Replace with logged-in user ID
                              );

                              setState(() {}); // Refresh UI
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text("Registered for ${event['name']}")),
                              );
                            },
                            child: const Text("Register"),
                          )
                        : const Text(
                            "Full",
                            style: TextStyle(color: Colors.red),
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
