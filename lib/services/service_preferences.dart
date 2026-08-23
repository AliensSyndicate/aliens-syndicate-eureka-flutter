import '../interfaces/repository_preferences.dart';
import '../models/model_preferences.dart';

class PreferencesService {
  PreferencesService(this._repository);

  final PreferencesRepository _repository;

  AppPreferences load() => _repository.load();

  Future<void> setNarrationEnabled(bool enabled) =>
      _repository.save(load().copyWith(narrationEnabled: enabled));

  Future<void> setReducedMotion(bool enabled) =>
      _repository.save(load().copyWith(reducedMotion: enabled));

  Future<void> dismissSaveProgressPrompt() =>
      _repository.save(load().copyWith(saveProgressPromptDismissed: true));
}
