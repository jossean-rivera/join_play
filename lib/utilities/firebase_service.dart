import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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
          .where('dateTime',
              isGreaterThan: Timestamp.now()) // Filter future events
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
      await eventDoc.update({
        'registeredUsers': FieldValue.arrayUnion([userId]),
        'slotsAvailable': FieldValue.increment(-1), // Decrement available slots
      });
      print('User $userId registered for event $eventId');
    } catch (e) {
      print('Error registering for event: $e');
    }
  }

  /// Gets the user reference from the database based on the given user id.
  DocumentReference<Map<String, dynamic>> getUserDocumentReference(
      String userId) {
    return _firestore.collection('users').doc(userId);
  }

  /// Creates game event in database
  Future<String?> createEvent(SportEvent event) async {
    try {
      var eventMap = event.toMap();
      final registrationDoc = _firestore.collection('events-collection').doc();
      await registrationDoc.set(eventMap);

      return null;
    } catch (e) {
      debugPrint('Failed to save new game event $e');
      return 'There was an error while trying to save a new game. Please try again later.';
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
}
