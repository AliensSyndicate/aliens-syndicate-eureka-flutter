import 'dart:io';

import 'package:eureka/data/local/hive_progress_repository.dart';
import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/models/model_activity_result.dart';
import 'package:eureka/models/model_lesson_session.dart';
import 'package:eureka/services/service_progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory directory;
  late Box<dynamic> box;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('progress_service');
    Hive.init(directory.path);
    box = await Hive.openBox<dynamic>('progress');
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('dados locais corrompidos usam valores seguros', () async {
    await box.putAll({
      'xp': 'inválido',
      'completed_lessons': 'inválido',
      'last_lesson_id': 42,
      'difficulty_subjects': {'mathematics': 'inválido', 'fractions': 2},
    });

    final service = ProgressService(HiveProgressRepository(box));

    expect(service.load().xp, 0);
    expect(service.load().completedLessonIds, isEmpty);
    expect(service.load().lastLessonId, isNull);
    expect(service.loadDifficultyScores(), {'fractions': 2});
  });

  test('persiste snapshot mínimo do resultado da atividade', () async {
    final service = ProgressService(HiveProgressRepository(box));
    final completedAt = DateTime(2026, 8, 22, 15);
    final snapshot = ActivityResultSnapshot(
      attemptId: 'attempt-1',
      lessonId: 'fractions',
      lessonTitle: 'Frações',
      subjectId: 'mathematics',
      activityVersion: 2,
      questionIds: const ['q1', 'q2'],
      correctAnswers: 1,
      totalQuestions: 2,
      earnedXp: 10,
      duration: const Duration(minutes: 4),
      reviewTopics: const ['fractions'],
      completedAt: completedAt,
    );

    await service.saveActivityResult(snapshot);
    final restored = service.loadLatestActivityResult('fractions');

    expect(restored?.attemptId, 'attempt-1');
    expect(restored?.activityVersion, 2);
    expect(restored?.duration, const Duration(minutes: 4));
    expect(restored?.completedAt, completedAt);
  });

  test('calcula atividades concluídas sobre o total da matéria', () async {
    final service = ProgressService(HiveProgressRepository(box));
    final lessons = seedLessons.take(2).toList();
    final firstQuestionIds = lessons.first.practiceQuestions
        .map((question) => question.id)
        .toList();
    await service.saveLessonSession(
      lessons.first.id,
      LessonSession(
        questionIds: firstQuestionIds,
        results: {
          firstQuestionIds[0]: true,
          firstQuestionIds[1]: false,
          firstQuestionIds[2]: true,
        },
      ),
    );

    final partialProgress = service.activityProgress(lessons);

    expect(partialProgress.completed, 0);
    expect(partialProgress.total, 2);

    await service.completeLesson(lessons.first.id, 0);
    final completedProgress = service.activityProgress(lessons);

    expect(completedProgress.completed, 1);
    expect(completedProgress.total, 2);
  });

  test('formata progresso com ao menos dois dígitos', () {
    expect(AppStrings.progressRatio(0, 0), '00/00');
    expect(AppStrings.progressRatio(3, 10), '03/10');
    expect(AppStrings.progressRatio(25, 25), '25/25');
  });
}
