import 'package:eureka/controllers/controller_simulation.dart';
import 'package:eureka/interfaces/repository_simulation.dart';
import 'package:eureka/models/model_simulation.dart';
import 'package:eureka/pages/simulation/page_simulation_question.dart';
import 'package:eureka/pages/simulation/page_simulation_result.dart';
import 'package:eureka/pages/simulation/page_simulation_review.dart';
import 'package:eureka/services/service_simulation.dart';
import 'package:eureka/ui/ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/simulation_fixtures.dart';

void main() {
  late DateTime now;
  late _MemoryRepository repository;
  late SimulationController controller;

  setUp(() {
    now = DateTime.now();
    repository = _MemoryRepository();
    final questions = SimulationService().buildQuestions(
      simulationLessons(),
      count: 2,
    );
    final session = SimulationSession(
      id: 'widget-session',
      startedAt: now,
      endTime: now.add(const Duration(minutes: 10)),
      questions: questions,
    );
    controller = SimulationController(
      repository: repository,
      service: SimulationService(),
      session: session,
      now: () => now,
    );
  });

  testWidgets('prova não revela correção e não mostra navegação principal', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.dark,
        home: PageSimulationQuestion(controller: controller),
      ),
    );

    expect(find.text('Correto!'), findsNothing);
    expect(find.text('Incorreto!'), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label?.startsWith('Tempo restante:') == true,
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('resultado apresenta métricas coerentes', (tester) async {
    await controller.answer(controller.current.question.correctAnswer);
    final result = controller.result();
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.dark,
        home: PageSimulationResult(controller: controller, result: result),
      ),
    );

    expect(find.text('1', skipOffstage: false), findsWidgets);
    expect(find.text('acertos'), findsOneWidget);
    expect(find.text('em branco'), findsOneWidget);
    expect(find.text('Por matéria'), findsOneWidget);
    expect(find.text('Por conteúdo'), findsOneWidget);
  });

  testWidgets('revisão mostra resposta, correta e explicação sem cronômetro', (
    tester,
  ) async {
    await controller.answer(controller.current.question.correctAnswer);
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.dark,
        home: PageSimulationReview(controller: controller),
      ),
    );

    expect(find.text('Sua resposta'), findsOneWidget);
    expect(find.text('Resposta correta'), findsOneWidget);
    expect(find.text('Entenda por quê'), findsOneWidget);
    expect(find.textContaining('Tempo restante'), findsNothing);
  });
}

class _MemoryRepository implements SimulationRepository {
  SimulationSession? active;
  final completed = <String, CompletedSimulation>{};

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
    completed[simulation.session.id] = simulation;
  }
}
