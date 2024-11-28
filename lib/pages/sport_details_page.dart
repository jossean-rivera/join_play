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
  String userId = "testUserId"; // Replace with actual logged-in user ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details for ${widget.sportId}"),
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
            final events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final isRegistered = event['registeredUsers']?.contains(userId) ?? false;

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
                    trailing: ElevatedButton(
                      onPressed: () async {
                        if (isRegistered) {
                          await firebaseService.unregisterFromEvent(event['id'], userId);
                        } else {
                          await firebaseService.registerForEvent(event['id'], userId);
                        }

                        setState(() {}); // Refresh UI
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRegistered ? Colors.red : Colors.green,
                      ),
                      child: Text(isRegistered ? "Unregister" : "Register"),
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
