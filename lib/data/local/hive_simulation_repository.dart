import 'package:hive_flutter/hive_flutter.dart';

import '../../enums/question_type.dart';
import '../../enums/subject_type.dart';
import '../../interfaces/repository_simulation.dart';
import '../../models/model_matching_pair.dart';
import '../../models/model_question.dart';
import '../../models/model_simulation.dart';

class HiveSimulationRepository implements SimulationRepository {
  HiveSimulationRepository(this._box);
  final Box<dynamic> _box;
  static const _key = 'active_simulation_v1';
  static const _resultsKey = 'simulation_results_v1';

  @override
  SimulationSession? loadActive() {
    final stored = _box.get(_key);
    if (stored is! Map) return null;
    try {
      final map = Map<String, dynamic>.from(stored);
      final status = SimulationStatus.values.byName(map['status'] as String);
      if (status != SimulationStatus.active) return null;
      return _sessionFromMap(map);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> saveActive(SimulationSession session) =>
      _box.put(_key, _sessionToMap(session));

  @override
  Future<void> saveCompleted(CompletedSimulation simulation) async {
    final stored = _box.get(_resultsKey);
    final results = stored is Map
        ? Map<String, dynamic>.from(stored)
        : <String, dynamic>{};
    results[simulation.session.id] = {
      'schemaVersion': 1,
      'completedAt': simulation.completedAt.toIso8601String(),
      'session': _sessionToMap(simulation.session),
      'result': _resultToMap(simulation.result),
    };
    await _box.put(_resultsKey, results);
  }

  @override
  CompletedSimulation? loadCompleted(String sessionId) {
    try {
      final stored = _box.get(_resultsKey);
      if (stored is! Map || stored[sessionId] is! Map) return null;
      final map = Map<String, dynamic>.from(stored[sessionId] as Map);
      return CompletedSimulation(
        session: _sessionFromMap(
          Map<String, dynamic>.from(map['session'] as Map),
        ),
        result: _resultFromMap(Map<String, dynamic>.from(map['result'] as Map)),
        completedAt: DateTime.parse(map['completedAt'] as String),
      );
    } on Object {
      return null;
    }
  }

  static Map<String, dynamic> _sessionToMap(SimulationSession session) => {
    'schemaVersion': 1,
    'id': session.id,
    'startedAt': session.startedAt.toIso8601String(),
    'endTime': session.endTime.toIso8601String(),
    'currentIndex': session.currentIndex,
    'answers': session.answers,
    'reviewQuestionIds': session.reviewQuestionIds.toList(),
    'status': session.status.name,
    'questions': session.questions.map(_questionToMap).toList(),
  };

  static SimulationSession _sessionFromMap(Map<String, dynamic> map) {
    final questions = (map['questions'] as List)
        .whereType<Map>()
        .map((item) => _questionFromMap(Map<String, dynamic>.from(item)))
        .toList();
    if (questions.isEmpty) throw const FormatException('Empty simulation');
    return SimulationSession(
      id: map['id'] as String,
      startedAt: DateTime.parse(map['startedAt'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      currentIndex: (map['currentIndex'] as int).clamp(0, questions.length - 1),
      answers: Map<String, String>.from(map['answers'] as Map? ?? const {}),
      reviewQuestionIds: Set<String>.from(
        map['reviewQuestionIds'] as List? ?? const [],
      ),
      status: SimulationStatus.values.byName(map['status'] as String),
      questions: questions,
    );
  }

  static Map<String, dynamic> _resultToMap(SimulationResult result) => {
    'correctAnswers': result.correctAnswers,
    'totalQuestions': result.totalQuestions,
    'unansweredQuestions': result.unansweredQuestions,
    'durationUsedSeconds': result.durationUsed.inSeconds,
    'bySubject': result.bySubject.map(_breakdownToMap).toList(),
    'byContent': result.byContent.map(_breakdownToMap).toList(),
    'reviewTopics': result.reviewTopics,
    'strongTopics': result.strongTopics,
  };

  static Map<String, dynamic> _breakdownToMap(SimulationBreakdown item) => {
    'label': item.label,
    'correct': item.correct,
    'total': item.total,
  };

  static SimulationResult _resultFromMap(
    Map<String, dynamic> map,
  ) => SimulationResult(
    correctAnswers: map['correctAnswers'] as int,
    totalQuestions: map['totalQuestions'] as int,
    unansweredQuestions: map['unansweredQuestions'] as int,
    durationUsed: Duration(seconds: map['durationUsedSeconds'] as int),
    bySubject: _breakdownsFromMap(map['bySubject']),
    byContent: _breakdownsFromMap(map['byContent']),
    reviewTopics: List<String>.from(map['reviewTopics'] as List? ?? const []),
    strongTopics: List<String>.from(map['strongTopics'] as List? ?? const []),
  );

  static List<SimulationBreakdown> _breakdownsFromMap(Object? value) =>
      (value as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) => SimulationBreakdown(
              label: item['label'] as String,
              correct: item['correct'] as int,
              total: item['total'] as int,
            ),
          )
          .toList();

  @override
  Future<void> clearActive() => _box.delete(_key);

  static Map<String, dynamic> _questionToMap(SimulationQuestion item) => {
    'subject': item.subject.name,
    'subjectTitle': item.subjectTitle,
    'contentTitle': item.contentTitle,
    'contentId': item.contentId,
    'question': {
      'id': item.question.id,
      'prompt': item.question.prompt,
      'type': item.question.type.name,
      'options': item.question.options,
      'correctAnswer': item.question.correctAnswer,
      'subjectId': item.question.subjectId,
      'topicId': item.question.topicId,
      'explanation': item.question.explanation,
      'pairs': item.question.pairs
          ?.map((pair) => {'left': pair.left, 'right': pair.right})
          .toList(),
      'template': item.question.template,
      'difficulty': item.question.difficulty,
      'tags': item.question.tags,
      'version': item.question.version,
      'usage': item.question.usage.name,
      'instruction': item.question.instruction,
      'acceptedAnswers': item.question.acceptedAnswers,
      'caseSensitive': item.question.caseSensitive,
      'ignoreAccents': item.question.ignoreAccents,
    },
  };

  static SimulationQuestion _questionFromMap(Map<String, dynamic> map) {
    final raw = Map<String, dynamic>.from(map['question'] as Map);
    final pairs = (raw['pairs'] as List?)
        ?.whereType<Map>()
        .map(
          (pair) => MatchingPair(
            left: pair['left'] as String,
            right: pair['right'] as String,
          ),
        )
        .toList();
    return SimulationQuestion(
      subject: SubjectType.values.byName(map['subject'] as String),
      subjectTitle: map['subjectTitle'] as String,
      contentTitle: map['contentTitle'] as String,
      contentId: map['contentId'] as String? ?? '',
      question: Question(
        id: raw['id'] as String,
        prompt: raw['prompt'] as String,
        type: QuestionType.values.byName(raw['type'] as String),
        options: List<String>.from(raw['options'] as List),
        correctAnswer: raw['correctAnswer'] as String,
        subjectId: raw['subjectId'] as String,
        topicId: raw['topicId'] as String,
        explanation: raw['explanation'] as String? ?? '',
        pairs: pairs,
        template: raw['template'] as String?,
        difficulty: raw['difficulty'] as int? ?? 1,
        tags: List<String>.from(raw['tags'] as List? ?? const []),
        version: raw['version'] as int? ?? 1,
        usage: QuestionUsage.values.byName(
          raw['usage'] as String? ?? QuestionUsage.simulatorExplore.name,
        ),
        instruction: raw['instruction'] as String? ?? '',
        acceptedAnswers: List<String>.from(
          raw['acceptedAnswers'] as List? ?? const [],
        ),
        caseSensitive: raw['caseSensitive'] as bool? ?? true,
        ignoreAccents: raw['ignoreAccents'] as bool? ?? false,
      ),
    );
  }
}
