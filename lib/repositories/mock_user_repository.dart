import 'package:join_play/models/sport_user.dart';
import 'package:join_play/repositories/user_repository.dart';

class MockUserRepository extends UserRepository {
  final Map<String, SportUser> _mockDatabase = {};

  @override
  Future<void> addUser(SportUser userData) {
    _mockDatabase[userData.uuid] = userData;
    return Future.value();
  }

  @override
  Future<SportUser?> getUser(String userId) {
    return Future.value(_mockDatabase[userId]);
  }
}
