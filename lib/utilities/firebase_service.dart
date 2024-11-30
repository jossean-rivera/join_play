import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:join_play/models/sport_event.dart';

class FirebaseService {
  final FirebaseFirestore _firestore;

  FirebaseService(this._firestore);

  // Fetch all sports
  Future<List<Map<String, dynamic>>> getSports() async {
    try {
      final snapshot = await _firestore.collection('sports').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include the document ID
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching sports: $e');
      return [];
    }
  }

  // Fetch events for a specific sport
  Future<List<SportEvent>> getEventsForSport(String sportId) async {
    try {
      final snapshot = await _firestore
          .collection('events-collection')
          .where('sportId', isEqualTo: sportId)
          .where('dateTime', isGreaterThan: Timestamp.now()) // Filter future events
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include the document ID
        return SportEvent.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error fetching events for sport $sportId: $e');
      return [];
    }
  }

  // Register a user for an event
  Future<void> registerForEvent(String eventId, String userId) async {
  try {
    final eventDoc = _firestore.collection('events-collection').doc(eventId);

    // Add user to the event's registered users list and decrement available slots
    await eventDoc.update({
      'registeredUsers': FieldValue.arrayUnion([userId]),
      'slotsAvailable': FieldValue.increment(-1), // Decrement available slots
    });

    // Add a new document in the registration collection
    final registrationDoc = _firestore.collection('registration').doc();
    await registrationDoc.set({
      'eventId': eventId,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(), // Optional: track registration time
    });

    print('User $userId successfully registered for event $eventId');
  } catch (e) {
    print('Error registering for event: $e');
  }
}

  // Fetch host details using Reference
  Future<String> getHostName(DocumentReference hostUserRef) async {
    try {
      final userDoc = await hostUserRef.get();
      return userDoc.exists ? userDoc['name'] ?? 'Unknown' : 'Unknown';
    } catch (e) {
      print('Error fetching host name: $e');
      return 'Unknown';
    }
  }

  Future<void> unregisterFromEvent(String eventId, String userId) async {
    try {
      // Reference to the event document
      final eventDoc = _firestore.collection('events-collection').doc(eventId);

      // Update the registeredUsers array and increment slotsAvailable
      await eventDoc.update({
        'registeredUsers': FieldValue.arrayRemove([userId]),
        'slotsAvailable': FieldValue.increment(1), // Increment available slots
      });

      // Query and delete the user's registration entry from the registration collection
      final registrationQuery = await _firestore
          .collection('registration')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in registrationQuery.docs) {
        await doc.reference.delete(); // Delete registration document
      }

      print('User $userId successfully unregistered from event $eventId');
    } catch (e) {
      print('Error unregistering from event: $e');
    }
  }
}