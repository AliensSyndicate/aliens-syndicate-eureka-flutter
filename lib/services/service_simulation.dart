import '../models/model_question.dart';
import '../models/model_simulation.dart';

class SimulationService {
  static const double strongThreshold = .8;
  static const double weakThreshold = .6;
  SimulationResult evaluate(
    List<Question> questions,
    Map<String, String> answers,
  ) {
    final correct = questions
        .where(
          (q) =>
              answers[q.id]?.trim().toLowerCase() ==
              q.correctAnswer.toLowerCase(),
        )
        .length;
    final grouped = <String, List<Question>>{};
    for (final question in questions) {
      grouped.putIfAbsent(question.topicId, () => []).add(question);
    }
    double rate(List<Question> group) =>
        group
            .where(
              (q) =>
                  answers[q.id]?.trim().toLowerCase() ==
                  q.correctAnswer.toLowerCase(),
            )
            .length /
        group.length;
    final review = grouped.entries
        .where((entry) => rate(entry.value) < weakThreshold)
        .map((entry) => entry.key)
        .toList();
    final strong = grouped.entries
        .where((entry) => rate(entry.value) >= strongThreshold)
        .map((entry) => entry.key)
        .toList();
    return SimulationResult(
      correctAnswers: correct,
      totalQuestions: questions.length,
      reviewTopics: review,
      strongTopics: strong,
    );
  }
}
