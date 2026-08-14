import 'package:eureka/services/service_scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calcula XP apenas a partir de acertos da jornada', () {
    expect(ScoringService().calculateJourneyXp(correctAnswers: 3), 30);
  });
}
