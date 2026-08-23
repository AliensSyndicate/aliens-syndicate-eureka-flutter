import 'package:hive_flutter/hive_flutter.dart';

import '../../interfaces/repository_preferences.dart';
import '../../models/model_preferences.dart';

class HivePreferencesRepository implements PreferencesRepository {
  HivePreferencesRepository(this._box);

  final Box<dynamic> _box;
  static const _key = 'app_preferences_v1';

  @override
  AppPreferences load() {
    final stored = _box.get(_key);
    if (stored is! Map) return const AppPreferences();
    return AppPreferences(
      narrationEnabled: stored['narrationEnabled'] as bool? ?? true,
      reducedMotion: stored['reducedMotion'] as bool? ?? false,
      saveProgressPromptDismissed:
          stored['saveProgressPromptDismissed'] as bool? ?? false,
    );
  }

  @override
  Future<void> save(AppPreferences preferences) => _box.put(_key, {
    'schemaVersion': 1,
    'narrationEnabled': preferences.narrationEnabled,
    'reducedMotion': preferences.reducedMotion,
    'saveProgressPromptDismissed': preferences.saveProgressPromptDismissed,
  });
}
