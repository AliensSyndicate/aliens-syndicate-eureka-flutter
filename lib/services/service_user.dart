import 'package:hive_flutter/hive_flutter.dart';
import '../models/model_user.dart';

class UserService {
  UserService(this._box);
  final Box<dynamic> _box;
  static const _key = 'current_user';
  static const temporaryUser = AppUser(
    id: 'local_test_user',
    displayName: 'Explorador',
    schoolYear: 5,
    isTemporary: true,
  );
  AppUser loadCurrentUser() {
    final stored = _box.get(_key);
    if (stored is Map) return AppUser.fromMap(stored);
    _box.put(_key, temporaryUser.toMap());
    return temporaryUser;
  }
}
