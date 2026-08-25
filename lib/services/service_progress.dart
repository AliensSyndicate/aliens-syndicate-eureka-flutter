import '../interfaces/repository_progress.dart';
import '../models/model_progress.dart';
import '../models/model_lesson.dart';
import '../models/model_lesson_session.dart';
import '../models/model_activity_result.dart';
import 'service_subject_progress.dart';

class ProgressService {
  ProgressService(this._repository);
  final ProgressRepository _repository;

  LessonSession loadLessonSession(String lessonId) {
    return _repository.loadLessonSession(lessonId);
  }

  Future<void> saveLessonSession(String lessonId, LessonSession session) {
    return _repository.saveLessonSession(lessonId, session);
  }

  UserProgress load() {
    return _repository.loadProgress();
  }

  int completionPercentage(List<Lesson> lessons) {
    return SubjectProgressService().calculate(
      lessons,
      completedLessonIdsFor(lessons),
    );
  }

  ({int completed, int total}) activityProgress(List<Lesson> lessons) {
    final completedLessonIds = completedLessonIdsFor(lessons);
    final completed = lessons
        .where((lesson) => completedLessonIds.contains(lesson.id))
        .length;
    return (completed: completed, total: lessons.length);
  }

  Set<String> completedLessonIdsFor(List<Lesson> lessons) {
    final completedLessonIds = load().completedLessonIds.toSet();
    for (final lesson in lessons) {
      final session = loadLessonSession(lesson.id);
      if (session.completed &&
          session.activityVersion == lesson.activityVersion) {
        completedLessonIds.add(lesson.id);
      }
    }
    return completedLessonIds;
  }

  Map<String, int> loadDifficultyScores() {
    return _repository.loadDifficultyScores();
  }

  Future<void> recordDifficulty(String subjectId) async {
    final scores = loadDifficultyScores();
    scores[subjectId] = (scores[subjectId] ?? 0) + 1;
    await _repository.saveDifficultyScores(scores);
  }

  Future<UserProgress> completeLesson(String lessonId, int earnedXp) async {
    final current = load();
    final ids = {...current.completedLessonIds, lessonId}.toList();
    final xp =
        current.xp +
        (current.completedLessonIds.contains(lessonId) ? 0 : earnedXp);
    final updated = UserProgress(
      xp: xp,
      completedLessonIds: ids,
      lastLessonId: lessonId,
    );
    await _repository.saveProgress(updated);
    return updated;
  }

  Future<void> saveActivityResult(ActivityResultSnapshot result) =>
      _repository.saveActivityResult(result);

  ActivityResultSnapshot? loadLatestActivityResult(String lessonId) =>
      _repository.loadLatestActivityResult(lessonId);
}
