import 'package:hive_flutter/hive_flutter.dart';

import '../../interfaces/repository_progress.dart';
import '../../models/model_lesson_session.dart';
import '../../models/model_activity_result.dart';
import '../../models/model_progress.dart';

class HiveProgressRepository implements ProgressRepository {
  HiveProgressRepository(this._box, {String? userId}) : _userId = userId;

  final Box<dynamic> _box;
  final String? _userId;
  Future<void> _pendingLessonSave = Future<void>.value();
  static const _lessonSessionsKey = 'lesson_sessions_v1';
  static const _legacyLessonSessionsKey = 'lesson_sessions';
  static const _activityResultsKey = 'activity_results_v1';

  String _key(String value) => _userId == null ? value : 'user.$_userId.$value';

  @override
  LessonSession loadLessonSession(String lessonId) {
    final sessions =
        _box.get(_key(_lessonSessionsKey)) ??
        (_userId == null ? _box.get(_legacyLessonSessionsKey) : null);
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
      final stored = _box.get(_key(_lessonSessionsKey));
      final sessions = stored is Map
          ? Map<String, dynamic>.from(stored)
          : <String, dynamic>{};
      sessions[lessonId] = snapshot;
      await _box.putAll({
        _key(_lessonSessionsKey): sessions,
        _key('last_lesson_id'): lessonId,
      });
    });
    return _pendingLessonSave;
  }

  @override
  UserProgress loadProgress() {
    final rawXp = _box.get(_key('xp'), defaultValue: 0);
    final rawCompleted = _box.get(
      _key('completed_lessons'),
      defaultValue: <String>[],
    );
    final rawLastLesson = _box.get(_key('last_lesson_id'));
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
    _key('xp'): progress.xp,
    _key('completed_lessons'): progress.completedLessonIds,
    _key('last_lesson_id'): progress.lastLessonId,
  });

  @override
  Map<String, int> loadDifficultyScores() {
    final stored =
        _box.get(_key('difficulty_subjects_v1')) ??
        (_userId == null ? _box.get('difficulty_subjects') : null);
    if (stored is! Map) return {};
    return {
      for (final entry in stored.entries)
        if (entry.value is int) entry.key.toString(): entry.value as int,
    };
  }

  @override
  Future<void> saveDifficultyScores(Map<String, int> scores) =>
      _box.put(_key('difficulty_subjects_v1'), scores);

  @override
  Future<void> saveActivityResult(ActivityResultSnapshot result) async {
    final stored = _box.get(_key(_activityResultsKey));
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
    await _box.put(_key(_activityResultsKey), results);
  }

  @override
  ActivityResultSnapshot? loadLatestActivityResult(String lessonId) {
    try {
      final stored = _box.get(_key(_activityResultsKey));
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
