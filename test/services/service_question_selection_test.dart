import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/services/service_question_selection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('evita repetição imediata quando existe alternativa', () {
    final pool = seedLessons.first.questions;
    final result = QuestionSelectionService().select(
      pool,
      count: 1,
      lastQuestionId: pool.first.id,
    );
    expect(result.single.id, pool.last.id);
  });
}
