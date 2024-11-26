import 'package:join_play/models/sport_user.dart';

abstract class UserRepository {
  Future<void> addUser(SportUser userData);
  Future<SportUser?> getUser(String userId);
}
