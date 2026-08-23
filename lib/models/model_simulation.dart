import '../enums/subject_type.dart';
import 'model_question.dart';

enum SimulationStatus { active, completed, expired, abandoned }

class SimulationConfiguration {
  const SimulationConfiguration({
    required this.subjects,
    required this.lessonIds,
    required this.questionCount,
    required this.duration,
  });
  final Set<SubjectType> subjects;
  final Set<String> lessonIds;
  final int questionCount;
  final Duration duration;
}

class SimulationQuestion {
  const SimulationQuestion({
    required this.question,
    required this.subject,
    required this.subjectTitle,
    required this.contentTitle,
    this.contentId = '',
  });
  final Question question;
  final SubjectType subject;
  final String subjectTitle;
  final String contentTitle;
  final String contentId;
}

class SimulationSession {
  const SimulationSession({
    required this.id,
    required this.startedAt,
    required this.endTime,
    required this.questions,
    this.currentIndex = 0,
    this.answers = const {},
    this.reviewQuestionIds = const {},
    this.status = SimulationStatus.active,
  });
  final String id;
  final DateTime startedAt;
  final DateTime endTime;
  final List<SimulationQuestion> questions;
  final int currentIndex;
  final Map<String, String> answers;
  final Set<String> reviewQuestionIds;
  final SimulationStatus status;

  Duration remainingAt(DateTime now) {
    final value = endTime.difference(now);
    return value.isNegative ? Duration.zero : value;
  }

  SimulationSession copyWith({
    int? currentIndex,
    Map<String, String>? answers,
    Set<String>? reviewQuestionIds,
    SimulationStatus? status,
  }) => SimulationSession(
    id: id,
    startedAt: startedAt,
    endTime: endTime,
    questions: questions,
    currentIndex: currentIndex ?? this.currentIndex,
    answers: answers ?? this.answers,
    reviewQuestionIds: reviewQuestionIds ?? this.reviewQuestionIds,
    status: status ?? this.status,
  );
}

class SimulationBreakdown {
  const SimulationBreakdown({
    required this.label,
    required this.correct,
    required this.total,
  });
  final String label;
  final int correct;
  final int total;
  double get score => total == 0 ? 0 : correct / total;
}

class SimulationResult {
  const SimulationResult({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.reviewTopics,
    this.unansweredQuestions = 0,
    this.durationUsed = Duration.zero,
    this.bySubject = const [],
    this.byContent = const [],
    this.strongTopics = const [],
  });
  final int correctAnswers;
  final int totalQuestions;
  final int unansweredQuestions;
  final Duration durationUsed;
  final List<SimulationBreakdown> bySubject;
  final List<SimulationBreakdown> byContent;
  final List<String> reviewTopics;
  final List<String> strongTopics;
  int get incorrectAnswers =>
      totalQuestions - correctAnswers - unansweredQuestions;
  double get score => totalQuestions == 0 ? 0 : correctAnswers / totalQuestions;
}

class CompletedSimulation {
  const CompletedSimulation({
    required this.session,
    required this.result,
    required this.completedAt,
  });

  final SimulationSession session;
  final SimulationResult result;
  final DateTime completedAt;
}
