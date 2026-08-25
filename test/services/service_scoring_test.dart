import 'package:eureka/services/service_scoring.dart';
import 'package:eureka/l10n/app_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calcula XP apenas a partir de acertos da jornada', () {
    expect(ScoringService().calculateJourneyXp(correctAnswers: 3), 60);
  });

  test('cada atividade correta vale 20 XP e a aula oferece até 100 XP', () {
    final service = ScoringService();
    expect(ScoringService.xpPerCorrectJourneyAnswer, 20);
    expect(ScoringService.activitiesPerJourneyLesson, 5);
    expect(ScoringService.maximumJourneyLessonXp, 100);
    expect(service.maximumJourneyXpForQuestionCount(3), 60);
    expect(service.maximumJourneyXpForQuestionCount(8), 100);
    expect(
      ScoringService().calculateJourneyXpFromResults([
        true,
        false,
        true,
        true,
        false,
      ]),
      60,
    );
    expect(AppStrings.earnUpToXp(100), 'Ganhe até 100 XP');
    expect(AppStrings.earnedXpGain(60), '+60 XP');
  });
}
