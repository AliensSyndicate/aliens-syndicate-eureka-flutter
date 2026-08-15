import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/services/service_subject_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('percentual de matéria usa aulas concluídas', () {
    final lessons = seedLessons.take(2).toList();
    final completed = {lessons.first.id};
    final percentage = SubjectProgressService().calculate(lessons, completed);
    expect(percentage, 50);
  });
}
