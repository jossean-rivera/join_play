import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:join_play/models/sport.dart';
import 'package:join_play/models/sport_event.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseService(this._firestore, this._storage);


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
    final eventDocRef = _firestore.collection('events-collection').doc(eventId);
    final userDocRef = _firestore.collection('users').doc(userId);

    // Add user to the event's registered users list (as a string) and decrement available slots
    await eventDocRef.update({
      'registeredUsers': FieldValue.arrayUnion([userId]), // Still stored as string in events-collection
      'slotsAvailable': FieldValue.increment(-1), // Decrement available slots
    });

    // Add a new document in the registration collection
    final registrationDoc = _firestore.collection('registration').doc();
    await registrationDoc.set({
      'eventId': eventDocRef, // Store as DocumentReference
      'userId': userDocRef,   // Store as DocumentReference
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
  DocumentReference<Map<String, dynamic>> getEventDocumentReference(String eventId) {
  return _firestore.collection('events-collection').doc(eventId);
  }


  /// Creates game event in database
  Future<String?> createEvent(SportEvent event) async {
  try {
    var eventMap = event.toMap();

    // Create a new document reference for the event
    final eventDocRef = _firestore.collection('events-collection').doc();

    // Save the event document
    await eventDocRef.set(eventMap);

    // Save the host document with eventId as a DocumentReference
    final hostLogDoc = _firestore.collection('host').doc();
    await hostLogDoc.set({
      'userId': event.hostUserId, // Keep userId as it is
      'eventId': eventDocRef, // Pass eventId as a DocumentReference
    });

    print('${event.hostUserId} created the event ${eventDocRef.id}');
  } catch (e) {
    debugPrint('Failed to save new game event $e');
    return 'There was an error while trying to save a new game. Please try again later.';
  }
  return null;
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

  Future<String?> unregisterFromEvent(String eventId, String userId) async {
  try {
    final eventDocRef = _firestore.collection('events-collection').doc(eventId);
    final userDocRef = _firestore.collection('users').doc(userId);

    // Update the registeredUsers array in events-collection and increment slotsAvailable
    await eventDocRef.update({
      'registeredUsers': FieldValue.arrayRemove([userId]), // Still stored as string in events-collection
      'slotsAvailable': FieldValue.increment(1), // Increment available slots
    });

    // Query the registration collection for entries with matching DocumentReferences
    final registrationQuery = await _firestore
        .collection('registration')
        .where('eventId', isEqualTo: eventDocRef) // Compare as DocumentReference
        .where('userId', isEqualTo: userDocRef)   // Compare as DocumentReference
        .get();

    // Delete the matching registration document(s)
    for (var doc in registrationQuery.docs) {
      await doc.reference.delete(); // Delete registration document
      return null;
    }
    print('User $userId successfully unregistered from event $eventId');
  } catch (e) {
    print('Error unregistering from event: $e');
  }
}

Future<List<SportEvent>> getUserRegisteredEvents(String userId, bool showFutureEvents) async {
  try {
    // Reference to the user document
    final userDocRef = _firestore.collection('users').doc(userId);

    // Query the registration collection to fetch event DocumentReferences for the user
    final registrationQuery = await _firestore
        .collection('registration')
        .where('userId', isEqualTo: userDocRef) // Use DocumentReference for userId
        .get();

    final eventDocRefs = registrationQuery.docs.map((doc) {
      final data = doc.data();
      return data['eventId'] as DocumentReference; // Fetch as DocumentReference
    }).toList();

    // Ensure eventDocRefs is not empty
    if (eventDocRefs.isEmpty) return [];

    // Fetch all events corresponding to the DocumentReferences
    final events = await Future.wait(
      eventDocRefs.map((eventDocRef) async {
        final eventSnapshot = await eventDocRef.get();
        if (!eventSnapshot.exists) return null;

        final data = eventSnapshot.data() as Map<String, dynamic>;
        data['id'] = eventSnapshot.id;

        // Filter future or past events based on showFutureEvents
        final eventDateTime = (data['dateTime'] as Timestamp).toDate();
        final isFutureEvent = eventDateTime.isAfter(DateTime.now());
        if (showFutureEvents ? isFutureEvent : !isFutureEvent) {
          return SportEvent.fromMap(data);
        }
        return null;
      }),
    );

    // Filter out null results and return the list of SportEvent
    return events.whereType<SportEvent>().toList();
  } catch (e) {
    print('Error fetching registered events: $e');
    return [];
  }
}

Future<List<SportEvent>> getUserPastEvents(String userId) async {
  try {
    // Reference to the user document
    final userDocRef = _firestore.collection('users').doc(userId);

    // Query the registration collection to fetch event DocumentReferences for the user
    final registrationQuery = await _firestore
        .collection('registration')
        .where('userId', isEqualTo: userDocRef) // Use DocumentReference for userId
        .get();

    final eventDocRefs = registrationQuery.docs.map((doc) {
      final data = doc.data();
      return data['eventId'] as DocumentReference; // Fetch as DocumentReference
    }).toList();

    // Ensure eventDocRefs is not empty
    if (eventDocRefs.isEmpty) return [];

    // Fetch all events corresponding to the DocumentReferences
    final pastEvents = await Future.wait(
      eventDocRefs.map((eventDocRef) async {
        final eventSnapshot = await eventDocRef.get();
        if (!eventSnapshot.exists) return null;

        final data = eventSnapshot.data() as Map<String, dynamic>;
        data['id'] = eventSnapshot.id;

        // Check if the event is a past event
        final eventDateTime = (data['dateTime'] as Timestamp).toDate();
        final isPastEvent = eventDateTime.isBefore(DateTime.now());
        if (isPastEvent) {
          return SportEvent.fromMap(data);
        }
        return null;
      }),
    );

    // Filter out null results and return the list of SportEvent
    return pastEvents.whereType<SportEvent>().toList();
  } catch (e) {
    print('Error fetching past events: $e');
    return [];
  }
}

  Future<List<SportEvent>> getHostedEvents(String userId) async {
  try {
    // Query the 'host' collection to get all event IDs where the user is the host
    final hostSnapshot = await _firestore
        .collection('host')
        .where('userId', isEqualTo: _firestore.collection('users').doc(userId)) // Match userId as DocumentReference
        .get();

    // Extract event IDs from the 'host' collection
    final eventIds = hostSnapshot.docs.map((doc) {
      final data = doc.data();
      final eventRef = data['eventId'] as DocumentReference?;
      return eventRef?.id; // Get the ID of the DocumentReference
    }).whereType<String>().toList(); // Remove nulls

    if (eventIds.isEmpty) {
      return []; // No hosted events found
    }

    // Query the 'events-collection' for events matching the retrieved IDs
    final eventSnapshot = await _firestore
        .collection('events-collection')
        .where(FieldPath.documentId, whereIn: eventIds) // Use event IDs
        .get();

    // Map the results to a list of SportEvent
    return eventSnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Include the document ID
      return SportEvent.fromMap(data);
    }).toList();
  } catch (e) {
    print('Error fetching hosted events: $e');
    return [];
  }
}
Future<List<String>> getUserNames(List<String> userIds) async {
  try {
    List<String> userNames = [];

    for (String userId in userIds) {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data['name'] != null) {
          userNames.add(data['name']);
        } else {
          userNames.add("Unknown"); // Fallback if the name is not found
        }
      }
    }
    return userNames;
  } catch (e) {
    print('Error fetching user names: $e');
    return [];
  }
}
  /// Uploads a profile picture to Firebase Storage and updates the Firestore user document
Future<void> uploadProfilePicture(String userId, String filePath) async {
  try {
    final File imageFile = File(filePath);

    // Reference to the storage location
    final storageRef = _storage.ref().child('profile_pictures/$userId.jpg');

    // Upload the file to Firebase Storage
    await storageRef.putFile(imageFile);

    // Get the download URL of the uploaded file
    final String downloadUrl = await storageRef.getDownloadURL();

    // Update the user document in Firestore with the download URL
    await _firestore.collection('users').doc(userId).update({
      'profilePicture': downloadUrl,
    });

    print('Profile picture uploaded successfully: $downloadUrl');
  } catch (e) {
    print('Error uploading profile picture: $e');
    throw e;
  }
}


  /// Deletes the profile picture from Firebase Storage and removes it from Firestore
  Future<void> deleteProfilePicture(String userId) async {
    try {
      // Reference to the storage location
      final storageRef = _storage.ref().child('profile_pictures/$userId.jpg');

      // Delete the image from Firebase Storage
      await storageRef.delete();

      // Remove the profilePicture field from the Firestore user document
      await _firestore.collection('users').doc(userId).update({
        'profilePicture': FieldValue.delete(),
      });

      print('Profile picture deleted successfully');
    } catch (e) {
      print('Error deleting profile picture: $e');
    }
  }
  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserDocument(String userId) {
  return _firestore.collection('users').doc(userId).get();
}

  /// Fetches the current user's profile picture URL
  Future<String?> getProfilePicture(String userId) async {
  try {
    final userDoc = await _getUserDocument(userId);
    if (userDoc.exists) {
      final data = userDoc.data(); // Safely retrieve data
      if (data != null && data['profilePicture'] != null) {
        return data['profilePicture'] as String; // Return profile picture URL
      }
    }
    return null; // Return null if no profile picture is found
  } catch (e) {
    print('Error fetching profile picture: $e');
    return null; // Return null in case of an error
  }
}
// Update user details
  Future<void> updateUserProfile(String userId, String name, String email) async {
    await _firestore.collection('users').doc(userId).update({
      'name': name,
      'email': email,
    });
  }

  // Delete user account
  Future<void> deleteAccount(String userId) async {
    // Delete user document
    await _firestore.collection('users').doc(userId).delete();

    // Delete user authentication
    await FirebaseAuth.instance.currentUser?.delete();
  }
}