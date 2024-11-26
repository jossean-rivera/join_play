import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:join_play/models/sport_user.dart';

import 'user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  FirestoreUserRepository(this._firestore);

  @override
  Future<void> addUser(SportUser userData) async {
    await _firestore
        .collection('users')
        .doc(userData.uuid)
        .set(userData.toMap());
  }

  @override
  Future<SportUser?> getUser(String userId) async {
    final docSnapshot = await _firestore.collection('users').doc(userId).get();
    Map<String, dynamic>? map = docSnapshot.data();
    return map == null ? null : SportUser.fromMap(map);
  }
}
