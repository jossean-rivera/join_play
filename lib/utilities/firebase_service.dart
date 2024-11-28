import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
/*
  // Fetch events for a specific sport
  Future<List<Map<String, dynamic>>> getEvents(String sportId) async {
    try {
      final snapshot = await _firestore
          .collection('sports')
          .doc(sportId)
          .collection('events')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include the document ID
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching events for sport $sportId: $e');
      return [];
    }
  }

  // Add a new event to the events subcollection
  Future<void> addEvent(String sportId, Map<String, dynamic> eventData) async {
    try {
      await _firestore
          .collection('sports')
          .doc(sportId)
          .collection('events')
          .add(eventData);
      print('Event added successfully');
    } catch (e) {
      print('Error adding event: $e');
    }
  }

  // Register a user for an event
  Future<void> registerForEvent(
      String sportId, String eventId, String userId) async {
    try {
      final eventDoc = _firestore
          .collection('sports')
          .doc(sportId)
          .collection('events')
          .doc(eventId);

      await eventDoc.update({
        'registered_users': FieldValue.arrayUnion([userId])
      });
      print('User $userId registered for event $eventId');
    } catch (e) {
      print('Error registering for event: $e');
    }
  }

  // Check if the user is already registered for an event (Optional)
  Future<bool> isUserRegistered(
      String sportId, String eventId, String userId) async {
    try {
      final eventDoc = await _firestore
          .collection('sports')
          .doc(sportId)
          .collection('events')
          .doc(eventId)
          .get();

      if (eventDoc.exists) {
        final data = eventDoc.data();
        final registeredUsers = data?['registered_users'] as List<dynamic>? ?? [];
        return registeredUsers.contains(userId);
      }
      return false;
    } catch (e) {
      print('Error checking user registration: $e');
      return false;
    }
  }*/
}
