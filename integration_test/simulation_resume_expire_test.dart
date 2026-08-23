import 'dart:io';

import 'package:eureka/controllers/controller_simulation.dart';
import 'package:eureka/data/local/hive_simulation_repository.dart';
import 'package:eureka/models/model_simulation.dart';
import 'package:eureka/services/service_simulation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/simulation_fixtures.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('retoma offline, recalcula o prazo e persiste expiração', (
    tester,
  ) async {
    final directory = await Directory.systemTemp.createTemp(
      'simulation_resume_expire',
    );
    addTearDown(() async {
      await Hive.close();
      await directory.delete(recursive: true);
    });
    Hive.init(directory.path);
    final box = await Hive.openBox<dynamic>('simulation_integration');
    final repository = HiveSimulationRepository(box);
    final startedAt = DateTime(2026, 8, 22, 10);
    final questions = SimulationService().buildQuestions(
      simulationLessons(),
      count: 2,
    );
    final firstController = SimulationController(
      repository: repository,
      service: SimulationService(),
      now: () => startedAt,
    );

    await firstController.start(questions, const Duration(minutes: 1));
    await firstController.answer(questions.first.question.correctAnswer);

    final restoredController = SimulationController(
      repository: repository,
      service: SimulationService(),
      now: () => startedAt.add(const Duration(minutes: 2)),
    );
    expect(
      restoredController.currentAnswer,
      questions.first.question.correctAnswer,
    );
    expect(
      restoredController.session.remainingAt(
        startedAt.add(const Duration(minutes: 2)),
      ),
      Duration.zero,
    );

    final result = await restoredController.complete(expired: true);

    expect(restoredController.session.status, SimulationStatus.expired);
    expect(result.correctAnswers, 1);
    expect(result.unansweredQuestions, 1);
    expect(repository.loadActive(), isNull);
    expect(
      repository.loadCompleted(restoredController.session.id)?.session.status,
      SimulationStatus.expired,
    );
  });
}
