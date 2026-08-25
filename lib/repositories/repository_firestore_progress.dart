import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../interfaces/repository_cloud_progress.dart';
import '../models/model_activity_result.dart';
import '../models/model_progress.dart';
import '../models/model_lesson_session.dart';

class FirestoreProgressRepository implements CloudProgressRepository {
  FirestoreProgressRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _userId => _auth.currentUser?.uid;

  @override
  Future<void> saveProgress(UserProgress progress) async {
    final userId = _userId;
    if (userId == null) return;
    await _firestore.doc('users/$userId/progress/current').set({
      'xp': progress.xp,
      'completedLessonIds': progress.completedLessonIds,
      'lastLessonId': progress.lastLessonId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> saveActivityResult(ActivityResultSnapshot result) async {
    final userId = _userId;
    if (userId == null) return;
    await _firestore
        .doc('users/$userId/activity_results/${result.lessonId}')
        .set({
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
          'completedAt': Timestamp.fromDate(result.completedAt),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<void> saveLessonRewardState(
    String lessonId,
    LessonSession session,
  ) async {
    final userId = _userId;
    if (userId == null) return;
    await _firestore.doc('users/$userId/lesson_rewards/$lessonId').set({
      'lessonId': lessonId,
      'activityVersion': session.activityVersion,
      'rewardedQuestionIds': session.rewardedQuestionIds,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
