import 'dart:math';

import '../enums/question_type.dart';
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

    // Modo teste: garante que a questão de matching apareça como 1ª atividade.
    final matchingIndex = ordered.indexWhere(
      (q) => q.type == QuestionType.matching,
    );
    if (matchingIndex != -1 && ordered[matchingIndex].id != lastQuestionId) {
      final matching = ordered.removeAt(matchingIndex);
      ordered.insert(0, matching);
    }

    return ordered.take(count.clamp(0, ordered.length)).toList();
  }
}
