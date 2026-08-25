import '../interfaces/repository_progress.dart';
import '../interfaces/repository_cloud_progress.dart';
import '../models/model_progress.dart';
import '../models/model_lesson.dart';
import '../models/model_lesson_session.dart';
import '../models/model_activity_result.dart';
import 'service_subject_progress.dart';

class ProgressService {
  ProgressService(this._repository, {CloudProgressRepository? cloudRepository})
    : _cloudRepository = cloudRepository;
  final ProgressRepository _repository;
  final CloudProgressRepository? _cloudRepository;

  LessonSession loadLessonSession(String lessonId) {
    return _repository.loadLessonSession(lessonId);
  }

  Future<void> saveLessonSession(String lessonId, LessonSession session) async {
    await _repository.saveLessonSession(lessonId, session);
    await _saveCloud(
      () => _cloudRepository?.saveLessonRewardState(lessonId, session),
    );
  }

  UserProgress load() {
    return _repository.loadProgress();
  }

  int projectedTotalXp(String lessonId, int earnedXp) {
    final current = load();
    return current.xp +
        (current.completedLessonIds.contains(lessonId) ? 0 : earnedXp);
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
    await _saveCloud(() => _cloudRepository?.saveProgress(updated));
    return updated;
  }

  Future<void> saveActivityResult(ActivityResultSnapshot result) async {
    await _repository.saveActivityResult(result);
    await _saveCloud(() => _cloudRepository?.saveActivityResult(result));
  }

  Future<void> _saveCloud(Future<void>? Function() operation) async {
    try {
      await operation();
    } on Object {
      // O Hive já confirmou a gravação. A experiência permanece offline-first.
    }
  }

  ActivityResultSnapshot? loadLatestActivityResult(String lessonId) =>
      _repository.loadLatestActivityResult(lessonId);
}
