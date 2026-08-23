import 'package:hive_flutter/hive_flutter.dart';

import '../../interfaces/repository_user.dart';
import '../../models/model_user.dart';

class HiveUserRepository implements UserRepository {
  HiveUserRepository(this._box);

  final Box<dynamic> _box;
  static const _key = 'current_user_v1';
  static const _legacyKey = 'current_user';

  @override
  AppUser? loadCurrentUser() {
    final stored = _box.get(_key) ?? _box.get(_legacyKey);
    if (stored is! Map) return null;
    try {
      return AppUser.fromMap(stored);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> saveCurrentUser(AppUser user) => _box.put(_key, user.toMap());
}
