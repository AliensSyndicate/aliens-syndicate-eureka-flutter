import 'model_lesson.dart';

class ActivityResult {
  const ActivityResult({
    required this.lesson,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.earnedXp,
    required this.duration,
    required this.reviewTopics,
  });

  final Lesson lesson;
  final int correctAnswers;
  final int totalQuestions;
  final int earnedXp;
  final Duration duration;
  final List<String> reviewTopics;
  double get score => totalQuestions == 0 ? 0 : correctAnswers / totalQuestions;
}

class ActivityResultSnapshot {
  const ActivityResultSnapshot({
    required this.attemptId,
    required this.lessonId,
    required this.lessonTitle,
    required this.subjectId,
    required this.activityVersion,
    required this.questionIds,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.earnedXp,
    required this.duration,
    required this.reviewTopics,
    required this.completedAt,
  });

  final String attemptId;
  final String lessonId;
  final String lessonTitle;
  final String subjectId;
  final int activityVersion;
  final List<String> questionIds;
  final int correctAnswers;
  final int totalQuestions;
  final int earnedXp;
  final Duration duration;
  final List<String> reviewTopics;
  final DateTime completedAt;
}
