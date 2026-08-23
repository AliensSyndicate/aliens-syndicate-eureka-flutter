import 'package:hive_flutter/hive_flutter.dart';

import '../../interfaces/repository_progress.dart';
import '../../models/model_lesson_session.dart';
import '../../models/model_activity_result.dart';
import '../../models/model_progress.dart';

class HiveProgressRepository implements ProgressRepository {
  HiveProgressRepository(this._box);

  final Box<dynamic> _box;
  Future<void> _pendingLessonSave = Future<void>.value();
  static const _lessonSessionsKey = 'lesson_sessions_v1';
  static const _legacyLessonSessionsKey = 'lesson_sessions';
  static const _activityResultsKey = 'activity_results_v1';

  @override
  LessonSession loadLessonSession(String lessonId) {
    final sessions =
        _box.get(_lessonSessionsKey) ?? _box.get(_legacyLessonSessionsKey);
    if (sessions is! Map || sessions[lessonId] is! Map) {
      return const LessonSession();
    }
    try {
      return LessonSession.fromMap(sessions[lessonId] as Map);
    } on Object {
      return const LessonSession();
    }
  }

  @override
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

  @override
  UserProgress loadProgress() {
    final rawXp = _box.get('xp', defaultValue: 0);
    final rawCompleted = _box.get(
      'completed_lessons',
      defaultValue: <String>[],
    );
    final rawLastLesson = _box.get('last_lesson_id');
    return UserProgress(
      xp: rawXp is int ? rawXp : 0,
      completedLessonIds: rawCompleted is List
          ? rawCompleted.whereType<String>().toList()
          : const [],
      lastLessonId: rawLastLesson is String ? rawLastLesson : null,
    );
  }

  @override
  Future<void> saveProgress(UserProgress progress) => _box.putAll({
    'xp': progress.xp,
    'completed_lessons': progress.completedLessonIds,
    'last_lesson_id': progress.lastLessonId,
  });

  @override
  Map<String, int> loadDifficultyScores() {
    final stored =
        _box.get('difficulty_subjects_v1') ?? _box.get('difficulty_subjects');
    if (stored is! Map) return {};
    return {
      for (final entry in stored.entries)
        if (entry.value is int) entry.key.toString(): entry.value as int,
    };
  }

  @override
  Future<void> saveDifficultyScores(Map<String, int> scores) =>
      _box.put('difficulty_subjects_v1', scores);

  @override
  Future<void> saveActivityResult(ActivityResultSnapshot result) async {
    final stored = _box.get(_activityResultsKey);
    final results = stored is Map
        ? Map<String, dynamic>.from(stored)
        : <String, dynamic>{};
    results[result.lessonId] = {
      'schemaVersion': 1,
      'attemptId': result.attemptId,
      'lessonId': result.lessonId,
      'lessonTitle': result.lessonTitle,
      'subjectId': result.subjectId,
      'activityVersion': result.activityVersion,
      'questionIds': result.questionIds,
      'correctAnswers': result.correctAnswers,
      'totalQuestions': result.totalQuestions,
      'earnedXp': result.earnedXp,
      'durationSeconds': result.duration.inSeconds,
      'reviewTopics': result.reviewTopics,
      'completedAt': result.completedAt.toIso8601String(),
    };
    await _box.put(_activityResultsKey, results);
  }

  @override
  ActivityResultSnapshot? loadLatestActivityResult(String lessonId) {
    try {
      final stored = _box.get(_activityResultsKey);
      if (stored is! Map || stored[lessonId] is! Map) return null;
      final map = Map<String, dynamic>.from(stored[lessonId] as Map);
      return ActivityResultSnapshot(
        attemptId: map['attemptId'] as String,
        lessonId: map['lessonId'] as String,
        lessonTitle: map['lessonTitle'] as String,
        subjectId: map['subjectId'] as String,
        activityVersion: map['activityVersion'] as int,
        questionIds: List<String>.from(map['questionIds'] as List),
        correctAnswers: map['correctAnswers'] as int,
        totalQuestions: map['totalQuestions'] as int,
        earnedXp: map['earnedXp'] as int,
        duration: Duration(seconds: map['durationSeconds'] as int),
        reviewTopics: List<String>.from(
          map['reviewTopics'] as List? ?? const [],
        ),
        completedAt: DateTime.parse(map['completedAt'] as String),
      );
    } on Object {
      return null;
    }
  }
}
