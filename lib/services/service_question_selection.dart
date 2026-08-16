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

    // Modo teste: garante que a questão de ordering apareça como 1ª atividade.
    final orderingIndex = ordered.indexWhere(
      (q) => q.type == QuestionType.ordering,
    );
    if (orderingIndex != -1 && ordered[orderingIndex].id != lastQuestionId) {
      final ordering = ordered.removeAt(orderingIndex);
      ordered.insert(0, ordering);
    }

    return ordered.take(count.clamp(0, ordered.length)).toList();
  }
}
