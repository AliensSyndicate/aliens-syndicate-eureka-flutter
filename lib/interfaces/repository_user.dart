import '../models/model_user.dart';

abstract interface class UserRepository {
  AppUser? loadCurrentUser();
  Future<void> saveCurrentUser(AppUser user);
}
