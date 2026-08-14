class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    this.unlocked = false,
  });
  final String id, title;
  final bool unlocked;
}
