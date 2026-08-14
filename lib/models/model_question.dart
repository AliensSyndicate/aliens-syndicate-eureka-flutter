import '../enums/question_type.dart';

class Question {
  const Question({
    required this.id,
    required this.prompt,
    required this.type,
    required this.options,
    required this.correctAnswer,
    required this.subjectId,
    required this.topicId,
    this.difficulty = 1,
    this.tags = const [],
    this.version = 1,
  });
  final String id, prompt, correctAnswer, subjectId, topicId;
  final QuestionType type;
  final List<String> options, tags;
  final int difficulty, version;
}
