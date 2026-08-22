import 'dart:io';

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

    final service = ProgressService(box);

    expect(service.load().xp, 0);
    expect(service.load().completedLessonIds, isEmpty);
    expect(service.load().lastLessonId, isNull);
    expect(service.loadDifficultyScores(), {'fractions': 2});
  });
}
