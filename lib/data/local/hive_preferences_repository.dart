import 'package:hive_flutter/hive_flutter.dart';

import '../../interfaces/repository_preferences.dart';
import '../../models/model_preferences.dart';

class HivePreferencesRepository implements PreferencesRepository {
  HivePreferencesRepository(this._box, {String? userId}) : _userId = userId;

  final Box<dynamic> _box;
  final String? _userId;
  static const _key = 'app_preferences_v1';
  String get _scopedKey => _userId == null ? _key : 'user.$_userId.$_key';

  @override
  AppPreferences load() {
    final stored = _box.get(_scopedKey);
    if (stored is! Map) return const AppPreferences();
    return AppPreferences(
      narrationEnabled: stored['narrationEnabled'] as bool? ?? true,
      reducedMotion: stored['reducedMotion'] as bool? ?? false,
      saveProgressPromptDismissed:
          stored['saveProgressPromptDismissed'] as bool? ?? false,
    );
  }

  @override
  Future<void> save(AppPreferences preferences) => _box.put(_scopedKey, {
    'schemaVersion': 1,
    'narrationEnabled': preferences.narrationEnabled,
    'reducedMotion': preferences.reducedMotion,
    'saveProgressPromptDismissed': preferences.saveProgressPromptDismissed,
  });
}
