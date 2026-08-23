import 'package:eureka/controllers/controller_simulation.dart';
import 'package:eureka/interfaces/repository_simulation.dart';
import 'package:eureka/models/model_simulation.dart';
import 'package:eureka/services/service_simulation.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/simulation_fixtures.dart';

void main() {
  test('salva respostas, navegação e marcação a cada mudança', () async {
    final repository = _MemorySimulationRepository();
    final now = DateTime(2026, 8, 22, 10);
    final controller = SimulationController(
      repository: repository,
      service: SimulationService(),
      now: () => now,
    );
    final questions = SimulationService().buildQuestions(
      simulationLessons(),
      count: 2,
    );

    await controller.start(questions, const Duration(minutes: 10));
    await controller.answer(questions.first.question.correctAnswer);
    await controller.toggleReview();
    await controller.goTo(1);

    expect(repository.active?.currentIndex, 1);
    expect(repository.active?.answers, hasLength(1));
    expect(repository.active?.reviewQuestionIds, {questions.first.question.id});
  });

  test('conclusão é durável e idempotente', () async {
    final repository = _MemorySimulationRepository();
    final now = DateTime(2026, 8, 22, 10);
    final controller = SimulationController(
      repository: repository,
      service: SimulationService(),
      now: () => now,
    );
    await controller.start(
      SimulationService().buildQuestions(simulationLessons(), count: 2),
      const Duration(minutes: 10),
    );

    final first = await controller.complete();
    final second = await controller.complete();

    expect(repository.completedWrites, 1);
    expect(repository.active, isNull);
    expect(second.totalQuestions, first.totalQuestions);
  });

  test('expiração é persistida com status próprio', () async {
    final repository = _MemorySimulationRepository();
    final now = DateTime(2026, 8, 22, 10);
    final controller = SimulationController(
      repository: repository,
      service: SimulationService(),
      now: () => now,
    );
    await controller.start(
      SimulationService().buildQuestions(simulationLessons(), count: 1),
      const Duration(minutes: 1),
    );
    await controller.complete(expired: true);

    expect(controller.session.status, SimulationStatus.expired);
    expect(
      repository.completed.values.single.session.status,
      SimulationStatus.expired,
    );
  });
}

class _MemorySimulationRepository implements SimulationRepository {
  SimulationSession? active;
  final completed = <String, CompletedSimulation>{};
  int completedWrites = 0;

  @override
  Future<void> clearActive() async => active = null;

  @override
  SimulationSession? loadActive() => active;

  @override
  CompletedSimulation? loadCompleted(String sessionId) => completed[sessionId];

  @override
  Future<void> saveActive(SimulationSession session) async => active = session;

  @override
  Future<void> saveCompleted(CompletedSimulation simulation) async {
    completedWrites++;
    completed[simulation.session.id] = simulation;
  }
}
