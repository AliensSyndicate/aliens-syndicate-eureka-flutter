import '../models/model_question.dart';

class QuestionSelectionService {
  List<Question> select(
    List<Question> pool, {
    required int count,
    String? lastQuestionId,
  }) {
    final ordered = [...pool];
    if (ordered.length > 1 && ordered.first.id == lastQuestionId) {
      ordered.add(ordered.removeAt(0));
    }
    return ordered.take(count.clamp(0, ordered.length)).toList();
  }
}
