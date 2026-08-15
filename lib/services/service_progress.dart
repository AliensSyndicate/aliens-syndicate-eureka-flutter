import 'package:hive_flutter/hive_flutter.dart';
import '../models/model_progress.dart';
import '../models/model_lesson.dart';
import 'service_subject_progress.dart';

class ProgressService {
  ProgressService(this._box);
  final Box<dynamic> _box;
  UserProgress load() => UserProgress(
    xp: _box.get('xp', defaultValue: 0) as int,
    completedLessonIds: List<String>.from(
      _box.get('completed_lessons', defaultValue: <String>[]),
    ),
  );
  int completionPercentage(List<Lesson> lessons) {
    return SubjectProgressService().calculate(
      lessons,
      load().completedLessonIds.toSet(),
    );
  }

  Future<UserProgress> completeLesson(String lessonId, int earnedXp) async {
    final current = load();
    final ids = {...current.completedLessonIds, lessonId}.toList();
    final xp =
        current.xp +
        (current.completedLessonIds.contains(lessonId) ? 0 : earnedXp);
    await _box.putAll({'xp': xp, 'completed_lessons': ids});
    return UserProgress(xp: xp, completedLessonIds: ids);
  }
}
