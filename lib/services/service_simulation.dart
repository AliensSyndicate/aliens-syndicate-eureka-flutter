import 'dart:math';

import '../enums/question_type.dart';
import '../enums/subject_type.dart';
import '../models/model_lesson.dart';
import '../models/model_question.dart';
import '../models/model_simulation.dart';
import 'service_answer.dart';

class SimulationService {
  SimulationService({Random? random, AnswerService? answerService})
    : _random = random ?? Random(),
      _answerService = answerService ?? AnswerService();

  static const double strongThreshold = .8;
  static const double weakThreshold = .6;
  static const compatibleTypes = {
    QuestionType.multipleChoice,
    QuestionType.trueFalse,
    QuestionType.textInput,
    QuestionType.fillBlank,
    QuestionType.wordCompletion,
    QuestionType.ordering,
    QuestionType.sequencing,
    QuestionType.matching,
  };
  final Random _random;
  final AnswerService _answerService;

  List<SimulationQuestion> buildQuestions(
    List<Lesson> lessons, {
    required int count,
  }) {
    final pools = <List<SimulationQuestion>>[];
    for (final lesson in lessons) {
      final source = lesson.extraQuestions.isNotEmpty
          ? lesson.extraQuestions
          : lesson.questions;
      final pool =
          source
              .where((question) => compatibleTypes.contains(question.type))
              .map(
                (question) => SimulationQuestion(
                  question: question,
                  subject: lesson.subject,
                  subjectTitle: _subjectTitle(lesson.subject),
                  contentTitle: lesson.title,
                ),
              )
              .toList()
            ..shuffle(_random);
      if (pool.isNotEmpty) pools.add(pool);
    }
    pools.shuffle(_random);
    final selected = <SimulationQuestion>[];
    var round = 0;
    while (selected.length < count) {
      var added = false;
      for (final pool in pools) {
        if (round < pool.length && selected.length < count) {
          selected.add(pool[round]);
          added = true;
        }
      }
      if (!added) break;
      round++;
    }
    selected.shuffle(_random);
    return selected;
  }

  SimulationResult evaluateSession(
    SimulationSession session, {
    DateTime? finishedAt,
  }) {
    bool isCorrect(SimulationQuestion item) {
      final answer = session.answers[item.question.id];
      return answer != null && _answerService.isCorrect(item.question, answer);
    }

    List<SimulationBreakdown> breakdown(
      String Function(SimulationQuestion) label,
    ) {
      final groups = <String, List<SimulationQuestion>>{};
      for (final item in session.questions) {
        groups.putIfAbsent(label(item), () => []).add(item);
      }
      return groups.entries
          .map(
            (entry) => SimulationBreakdown(
              label: entry.key,
              correct: entry.value.where(isCorrect).length,
              total: entry.value.length,
            ),
          )
          .toList();
    }

    final byContent = breakdown((item) => item.contentTitle);
    final maximum = session.endTime.difference(session.startedAt);
    final elapsed = (finishedAt ?? DateTime.now()).difference(
      session.startedAt,
    );
    return SimulationResult(
      correctAnswers: session.questions.where(isCorrect).length,
      totalQuestions: session.questions.length,
      unansweredQuestions: session.questions
          .where((item) => !session.answers.containsKey(item.question.id))
          .length,
      durationUsed: elapsed > maximum ? maximum : elapsed,
      bySubject: breakdown((item) => item.subjectTitle),
      byContent: byContent,
      reviewTopics: byContent
          .where((item) => item.score < weakThreshold)
          .map((item) => item.label)
          .toList(),
      strongTopics: byContent
          .where((item) => item.score >= strongThreshold)
          .map((item) => item.label)
          .toList(),
    );
  }

  SimulationResult evaluate(
    List<Question> questions,
    Map<String, String> answers,
  ) {
    final now = DateTime.now();
    return evaluateSession(
      SimulationSession(
        id: 'legacy',
        startedAt: now,
        endTime: now,
        answers: answers,
        questions: questions
            .map(
              (question) => SimulationQuestion(
                question: question,
                subject: _subjectFromId(question.subjectId),
                subjectTitle: question.subjectId,
                contentTitle: question.topicId,
              ),
            )
            .toList(),
      ),
      finishedAt: now,
    );
  }

  static String _subjectTitle(SubjectType subject) => switch (subject) {
    SubjectType.portuguese => 'Português',
    SubjectType.mathematics => 'Matemática',
    SubjectType.science => 'Ciências',
    SubjectType.history => 'História',
    SubjectType.geography => 'Geografia',
    _ => subject.name,
  };

  static SubjectType _subjectFromId(String id) => SubjectType.values.firstWhere(
    (subject) => subject.name == id,
    orElse: () => SubjectType.mathematics,
  );
}
