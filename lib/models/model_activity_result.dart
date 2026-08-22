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
