import 'dart:math';

import '../models/model_question.dart';

class QuestionSelectionService {
  QuestionSelectionService({Random? random}) : _random = random ?? Random();

  static const poolSize = 10;
  static const sessionSize = 5;

  final Random _random;

  List<Question> select(
    List<Question> pool, {
    required int count,
    String? lastQuestionId,
  }) {
    final ordered = [...pool]..shuffle(_random);
    if (ordered.length > 1 && ordered.first.id == lastQuestionId) {
      ordered.add(ordered.removeAt(0));
    }
    return ordered.take(count.clamp(0, ordered.length)).toList();
  }
}
