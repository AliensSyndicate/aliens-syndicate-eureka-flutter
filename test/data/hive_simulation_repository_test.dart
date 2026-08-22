import 'dart:io';

import 'package:eureka/data/local/hive_simulation_repository.dart';
import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/models/model_simulation.dart';
import 'package:eureka/services/service_simulation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory directory;
  late Box<dynamic> box;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('simulation_repository');
    Hive.init(directory.path);
    box = await Hive.openBox<dynamic>('simulation');
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('restaura sessão completa com prazo, resposta e marcação', () async {
    final questions = SimulationService().buildQuestions(seedLessons, count: 2);
    final now = DateTime(2026, 8, 22, 12);
    final session = SimulationSession(
      id: 'session-1',
      startedAt: now,
      endTime: now.add(const Duration(minutes: 10)),
      questions: questions,
      currentIndex: 1,
      answers: {
        questions.first.question.id: questions.first.question.correctAnswer,
      },
      reviewQuestionIds: {questions.last.question.id},
    );
    final repository = HiveSimulationRepository(box);

    await repository.saveActive(session);
    final restored = repository.loadActive();

    expect(restored?.id, session.id);
    expect(restored?.endTime, session.endTime);
    expect(restored?.currentIndex, 1);
    expect(restored?.answers, session.answers);
    expect(restored?.reviewQuestionIds, session.reviewQuestionIds);
    expect(restored?.questions.length, session.questions.length);
  });
}
