class UserProgress {
  const UserProgress({
    this.xp = 0,
    this.completedLessonIds = const [],
    this.lastLessonId,
  });
  final int xp;
  final List<String> completedLessonIds;
  final String? lastLessonId;
  int get level => (xp ~/ 100) + 1;
}
