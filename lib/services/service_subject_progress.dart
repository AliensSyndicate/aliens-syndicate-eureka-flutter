import '../models/model_lesson.dart';

class SubjectProgressService {
  int calculate(List<Lesson> lessons, Set<String> completedLessonIds) {
    if (lessons.isEmpty) return 0;
    final completed = lessons
        .where((lesson) => completedLessonIds.contains(lesson.id))
        .length;
    return ((completed / lessons.length) * 100).round();
  }
}
