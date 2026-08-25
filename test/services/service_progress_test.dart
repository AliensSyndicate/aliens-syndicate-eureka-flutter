import 'dart:io';

import 'package:eureka/data/local/hive_progress_repository.dart';
import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/interfaces/repository_cloud_progress.dart';
import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/models/model_activity_result.dart';
import 'package:eureka/models/model_lesson_session.dart';
import 'package:eureka/models/model_progress.dart';
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

  test('considera sessão atual finalizada no progresso da matéria', () async {
    final service = ProgressService(HiveProgressRepository(box));
    final lessons = seedLessons.take(2).toList();
    final lesson = lessons.first;
    await service.saveLessonSession(
      lesson.id,
      LessonSession(activityVersion: lesson.activityVersion, completed: true),
    );

    final progress = service.activityProgress(lessons);

    expect(progress.completed, 1);
    expect(service.completionPercentage(lessons), 50);
  });

  test('salva progresso local e agregado remoto autenticado', () async {
    final cloud = _RecordingCloudProgressRepository();
    final service = ProgressService(
      HiveProgressRepository(box),
      cloudRepository: cloud,
    );

    await service.saveLessonSession(
      'lesson_1',
      const LessonSession(rewardedQuestionIds: ['q1']),
    );
    await service.completeLesson('lesson_1', 40);
    final result = ActivityResultSnapshot(
      attemptId: 'attempt-sync',
      lessonId: 'lesson_1',
      lessonTitle: 'Frações',
      subjectId: 'mathematics',
      activityVersion: 1,
      questionIds: const ['q1', 'q2'],
      correctAnswers: 2,
      totalQuestions: 2,
      earnedXp: 40,
      duration: const Duration(minutes: 2),
      reviewTopics: const [],
      completedAt: DateTime(2026, 8, 25),
    );
    await service.saveActivityResult(result);

    expect(service.load().xp, 40);
    expect(cloud.progress?.xp, 40);
    expect(cloud.result?.attemptId, 'attempt-sync');
    expect(cloud.rewardSession?.rewardedQuestionIds, ['q1']);
  });

  test('formata progresso com ao menos dois dígitos', () {
    expect(AppStrings.progressRatio(0, 0), '00/00');
    expect(AppStrings.progressRatio(3, 10), '03/10');
    expect(AppStrings.progressRatio(25, 25), '25/25');
  });
}

class _RecordingCloudProgressRepository implements CloudProgressRepository {
  UserProgress? progress;
  ActivityResultSnapshot? result;
  LessonSession? rewardSession;

  @override
  Future<void> saveProgress(UserProgress progress) async {
    this.progress = progress;
  }

  @override
  Future<void> saveActivityResult(ActivityResultSnapshot result) async {
    this.result = result;
  }

  @override
  Future<void> saveLessonRewardState(
    String lessonId,
    LessonSession session,
  ) async {
    rewardSession = session;
  }
}
