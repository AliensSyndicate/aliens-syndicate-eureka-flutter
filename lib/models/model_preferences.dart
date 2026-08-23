class AppPreferences {
  const AppPreferences({
    this.narrationEnabled = true,
    this.reducedMotion = false,
    this.saveProgressPromptDismissed = false,
  });

  final bool narrationEnabled;
  final bool reducedMotion;
  final bool saveProgressPromptDismissed;

  AppPreferences copyWith({
    bool? narrationEnabled,
    bool? reducedMotion,
    bool? saveProgressPromptDismissed,
  }) => AppPreferences(
    narrationEnabled: narrationEnabled ?? this.narrationEnabled,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    saveProgressPromptDismissed:
        saveProgressPromptDismissed ?? this.saveProgressPromptDismissed,
  );
}
