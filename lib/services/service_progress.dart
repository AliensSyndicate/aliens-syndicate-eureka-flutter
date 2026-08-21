import 'package:hive_flutter/hive_flutter.dart';
import '../models/model_progress.dart';
import '../models/model_lesson.dart';
import '../models/model_lesson_session.dart';
import 'service_subject_progress.dart';

class ProgressService {
  ProgressService(this._box);
  final Box<dynamic> _box;
  Future<void> _pendingLessonSave = Future<void>.value();
  static const _lessonSessionsKey = 'lesson_sessions';

  LessonSession loadLessonSession(String lessonId) {
    final sessions = _box.get(_lessonSessionsKey);
    if (sessions is! Map || sessions[lessonId] is! Map) {
      return const LessonSession();
    }
    return LessonSession.fromMap(sessions[lessonId] as Map);
  }

  Future<void> saveLessonSession(String lessonId, LessonSession session) {
    final snapshot = session.toMap();
    _pendingLessonSave = _pendingLessonSave.then((_) async {
      final stored = _box.get(_lessonSessionsKey);
      final sessions = stored is Map
          ? Map<String, dynamic>.from(stored)
          : <String, dynamic>{};
      sessions[lessonId] = snapshot;
      await _box.putAll({
        _lessonSessionsKey: sessions,
        'last_lesson_id': lessonId,
      });
    });
    return _pendingLessonSave;
  }

  UserProgress load() => UserProgress(
    xp: _box.get('xp', defaultValue: 0) as int,
    completedLessonIds: List<String>.from(
      _box.get('completed_lessons', defaultValue: <String>[]),
    ),
    lastLessonId: _box.get('last_lesson_id') as String?,
  );
  int completionPercentage(List<Lesson> lessons) {
    return SubjectProgressService().calculate(
      lessons,
      load().completedLessonIds.toSet(),
    );
  }

  Map<String, int> loadDifficultyScores() {
    final stored = _box.get('difficulty_subjects');
    if (stored is! Map) return {};
    return stored.map((key, value) => MapEntry(key.toString(), value as int));
  }

  Future<void> recordDifficulty(String subjectId) async {
    final scores = loadDifficultyScores();
    scores[subjectId] = (scores[subjectId] ?? 0) + 1;
    await _box.put('difficulty_subjects', scores);
  }

  Future<UserProgress> completeLesson(String lessonId, int earnedXp) async {
    final current = load();
    final ids = {...current.completedLessonIds, lessonId}.toList();
    final xp =
        current.xp +
        (current.completedLessonIds.contains(lessonId) ? 0 : earnedXp);
    await _box.putAll({
      'xp': xp,
      'completed_lessons': ids,
      'last_lesson_id': lessonId,
    });
    return UserProgress(
      xp: xp,
      completedLessonIds: ids,
      lastLessonId: lessonId,
    );
  }
}
