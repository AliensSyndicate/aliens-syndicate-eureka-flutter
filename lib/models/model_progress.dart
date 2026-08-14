class UserProgress {
  const UserProgress({this.xp = 0, this.completedLessonIds = const []});
  final int xp;
  final List<String> completedLessonIds;
  int get level => (xp ~/ 100) + 1;
}
