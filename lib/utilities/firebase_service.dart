import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  /// Gets the user reference from the database based on the given user id.
  DocumentReference<Map<String, dynamic>> getUserDocumentReference(
      String userId) {
    return _firestore.collection('users').doc(userId);
  }

  /// Creates game event in database
  Future<String?> createEvent(SportEvent event, String userId) async {
    try {
      var eventMap = event.toMap();
      final registrationDoc = _firestore.collection('events-collection').doc();
      await registrationDoc.set(eventMap);

      final hostlogDoc = _firestore.collection('host').doc();
      await hostlogDoc.set({
        'userId' : userId,
        'eventId' : registrationDoc.id,
    });

          print('${userId} created the event ${registrationDoc.id}');
      
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
  Future<List<SportEvent>> getUserRegisteredEvents(String userId, bool showFutureEvents) async {
  try {
    // Query the registration collection to fetch event IDs for the user
    final registrationQuery = await _firestore
        .collection('registration')
        .where('userId', isEqualTo: userId)
        .get();

    final eventIds = registrationQuery.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['eventId'] as String;
    }).toList();

    // Ensure eventIds is not empty
    if (eventIds.isEmpty) return [];

    // Fetch all events from the collection and filter manually
    final eventsSnapshot = await _firestore.collection('events-collection').get();

    final filteredEvents = eventsSnapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final eventDateTime = data['dateTime'] as Timestamp;
      final isFutureEvent = eventDateTime.toDate().isAfter(DateTime.now());
      return eventIds.contains(doc.id) && (showFutureEvents ? isFutureEvent : !isFutureEvent);
    }).toList();

    return filteredEvents.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return SportEvent.fromMap(data);
    }).toList();
  } catch (e) {
    print('Error fetching registered events: $e');
    return [];
  }
}
Future<List<SportEvent>> getUserPastEvents(String userId) async {
  try {
    // Query the registration collection to fetch event IDs for the user
    final registrationQuery = await _firestore
        .collection('registration')
        .where('userId', isEqualTo: userId)
        .get();

    final eventIds = registrationQuery.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['eventId'] as String;
    }).toList();

    // Ensure eventIds is not empty
    if (eventIds.isEmpty) return [];

    // Fetch all events and filter manually for past events
    final eventsSnapshot = await _firestore.collection('events-collection').get();

    final pastEvents = eventsSnapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final eventDateTime = data['dateTime'] as Timestamp;
      final isPastEvent = eventDateTime.toDate().isBefore(DateTime.now());
      return eventIds.contains(doc.id) && isPastEvent;
    }).toList();

    return pastEvents.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return SportEvent.fromMap(data);
    }).toList();
  } catch (e) {
    print('Error fetching past events: $e');
    return [];
  }
}






}