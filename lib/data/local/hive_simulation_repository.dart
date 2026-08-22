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

  @override
  SimulationSession? loadActive() {
    final stored = _box.get(_key);
    if (stored is! Map) return null;
    try {
      final map = Map<String, dynamic>.from(stored);
      final status = SimulationStatus.values.byName(map['status'] as String);
      if (status != SimulationStatus.active) return null;
      return SimulationSession(
        id: map['id'] as String,
        startedAt: DateTime.parse(map['startedAt'] as String),
        endTime: DateTime.parse(map['endTime'] as String),
        currentIndex: map['currentIndex'] as int,
        answers: Map<String, String>.from(map['answers'] as Map? ?? const {}),
        reviewQuestionIds: Set<String>.from(
          map['reviewQuestionIds'] as List? ?? const [],
        ),
        status: status,
        questions: (map['questions'] as List)
            .whereType<Map>()
            .map((item) => _questionFromMap(Map<String, dynamic>.from(item)))
            .toList(),
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> saveActive(SimulationSession session) => _box.put(_key, {
    'schemaVersion': 1,
    'id': session.id,
    'startedAt': session.startedAt.toIso8601String(),
    'endTime': session.endTime.toIso8601String(),
    'currentIndex': session.currentIndex,
    'answers': session.answers,
    'reviewQuestionIds': session.reviewQuestionIds.toList(),
    'status': session.status.name,
    'questions': session.questions.map(_questionToMap).toList(),
  });

  @override
  Future<void> clearActive() => _box.delete(_key);

  static Map<String, dynamic> _questionToMap(SimulationQuestion item) => {
    'subject': item.subject.name,
    'subjectTitle': item.subjectTitle,
    'contentTitle': item.contentTitle,
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
