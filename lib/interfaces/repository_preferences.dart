import '../models/model_preferences.dart';

abstract interface class PreferencesRepository {
  AppPreferences load();
  Future<void> save(AppPreferences preferences);
}
