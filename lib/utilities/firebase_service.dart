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

  // Fetch events for a specific sport
  Future<List<Map<String, dynamic>>> getEventsForSport(String sportId) async {
    try {
      final snapshot = await _firestore
          .collection('events-collection')
          .where('sportId', isEqualTo: sportId)
          .where('dateTime', isGreaterThan: DateTime.now())
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

  // Register a user for an event
  Future<void> registerForEvent(String eventId, String userId) async {
    try {
      final eventRef = _firestore.collection('events-collection').doc(eventId);
      final registrationRef = _firestore.collection('registration').doc();

      await _firestore.runTransaction((transaction) async {
        final eventDoc = await transaction.get(eventRef);
        if (!eventDoc.exists) {
          throw Exception("Event does not exist");
        }

        final data = eventDoc.data();
        final slotsAvailable = data?['slotsAvailable'] ?? 0;

        if (slotsAvailable > 0) {
          transaction.update(eventRef, {
            'registeredUsers': FieldValue.arrayUnion([userId]),
            'slotsAvailable': FieldValue.increment(-1),
          });

          transaction.set(registrationRef, {
            'eventId': eventId,
            'userId': userId,
          });
        } else {
          throw Exception("No slots available");
        }
      });
    } catch (e) {
      print('Error registering for event: $e');
    }
  }

  // Unregister a user from an event
  Future<void> unregisterFromEvent(String eventId, String userId) async {
    try {
      final eventRef = _firestore.collection('events-collection').doc(eventId);
      final registrationQuery = _firestore
          .collection('registration')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId);

      await _firestore.runTransaction((transaction) async {
        final eventDoc = await transaction.get(eventRef);
        if (!eventDoc.exists) {
          throw Exception("Event does not exist");
        }

        final querySnapshot = await registrationQuery.get();
        for (var doc in querySnapshot.docs) {
          transaction.delete(doc.reference);
        }

        transaction.update(eventRef, {
          'registeredUsers': FieldValue.arrayRemove([userId]),
          'slotsAvailable': FieldValue.increment(1),
        });
      });
    } catch (e) {
      print('Error unregistering from event: $e');
    }
  }

  // Fetch the host's name (optional if you want to use it later)
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
  
