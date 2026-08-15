import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class HiveContentActivityCache {
  HiveContentActivityCache(this._box);
  final Box<dynamic> _box;

  Map<String, dynamic>? read(String activityId, int version) {
    final value = _box.get('activity.$activityId.$version') as String?;
    if (value == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(value) as Map);
    } on Object {
      return null;
    }
  }

  Future<void> write(
    String activityId,
    int version,
    Map<String, dynamic> value,
  ) => _box.put('activity.$activityId.$version', jsonEncode(value));
}
