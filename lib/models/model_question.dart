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
    this.explanation = '',
    this.pairs,
    this.template,
    this.difficulty = 1,
    this.tags = const [],
    this.version = 1,
  }) : assert(
         type != QuestionType.multipleChoice || options.length == 4,
         'Questão "$id": multipleChoice deve ter exatamente 4 alternativas, '
         'mas recebeu ${options.length}.',
       ),
       assert(
         type != QuestionType.matching || (pairs != null && pairs.length == 5),
         'Questão "$id": matching deve ter exatamente 5 pares.',
       ),
       assert(
         type != QuestionType.memory ||
             (pairs != null && pairs.length >= 2 && pairs.length <= 8),
         'Questão "$id": memory deve ter de 2 a 8 pares.',
       ),
       assert(
         type != QuestionType.trueFalse || options.length == 2,
         'Questão "$id": trueFalse deve ter exatamente 2 alternativas.',
       ),
       assert(
         type != QuestionType.imageChoice || options.length == 4,
         'Questão "$id": imageChoice deve ter exatamente 4 imagens.',
       ),
       assert(
         (type != QuestionType.fillBlank &&
                 type != QuestionType.wordCompletion) ||
             (template != null && template.contains(blankToken)),
         'Questão "$id": ${type.name} exige um template contendo '
         '"$blankToken" para marcar cada lacuna.',
       );

  /// Marcador de lacuna usado em [template].
  static const blankToken = '_';

  final String id, prompt, correctAnswer, subjectId, topicId;

  /// Explicação pedagógica exibida após uma tentativa incorreta.
  final String explanation;

  String get incorrectFeedback => explanation.trim().isNotEmpty
      ? explanation
      : 'Observe como a pergunta foi construída. A resposta correta é '
            '$correctAnswer.';
  final QuestionType type;
  final List<String> options, tags;

  /// Pares de ligação; obrigatório para [QuestionType.matching] e
  /// [QuestionType.memory].
  final List<MatchingPair>? pairs;

  /// Texto com lacunas marcadas por [blankToken]; obrigatório para
  /// [QuestionType.fillBlank] (frase) e [QuestionType.wordCompletion] (palavra).
  final String? template;

  final int difficulty, version;
}
