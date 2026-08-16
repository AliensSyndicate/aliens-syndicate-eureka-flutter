import '../enums/question_type.dart';
import 'model_matching_pair.dart';

class Question {
  Question({
    required this.id,
    required this.prompt,
    required this.type,
    required this.options,
    required this.correctAnswer,
    required this.subjectId,
    required this.topicId,
    this.pairs,
    this.difficulty = 1,
    this.tags = const [],
    this.version = 1,
  })  : assert(
          type != QuestionType.multipleChoice || options.length == 4,
          'Questão "$id": multipleChoice deve ter exatamente 4 alternativas, '
          'mas recebeu ${options.length}.',
        ),
        assert(
          type != QuestionType.matching ||
              (pairs != null && pairs.length == 5),
          'Questão "$id": matching deve ter exatamente 5 pares.',
        );

  final String id, prompt, correctAnswer, subjectId, topicId;
  final QuestionType type;
  final List<String> options, tags;

  /// Pares de ligação; obrigatório para [QuestionType.matching].
  final List<MatchingPair>? pairs;

  final int difficulty, version;
}
