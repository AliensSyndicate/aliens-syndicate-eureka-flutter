import 'dart:io';

import 'package:eureka/data/local/hive_content_activity_cache.dart';
import 'package:eureka/data/local/hive_content_manifest_cache.dart';
import 'package:eureka/enums/subject_type.dart';
import 'package:eureka/interfaces/repository_content.dart';
import 'package:eureka/models/content/model_activity_reference.dart';
import 'package:eureka/models/content/model_content_manifest.dart';
import 'package:eureka/models/model_lesson.dart';
import 'package:eureka/services/service_content.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory tempDirectory;
  late Box<dynamic> box;

  setUpAll(() async {
    tempDirectory = Directory.systemTemp.createTempSync('eureka_content_');
    Hive.init(tempDirectory.path);
    box = await Hive.openBox<dynamic>('content_runtime');
  });

  setUp(() => box.clear());

  tearDownAll(() async {
    await Hive.close();
    tempDirectory.deleteSync(recursive: true);
  });

  test('payload remoto malformado cai para seed sem lançar', () async {
    final service = ContentService(
      _MalformedRepository(),
      HiveContentManifestCache(box),
      HiveContentActivityCache(box),
    );
    const lesson = Lesson(
      id: 'mathematics_ef_5_2',
      title: 'Frações',
      summary: 'Resumo do catálogo',
      subject: SubjectType.mathematics,
      questions: [],
      activities: [ActivityReference(id: 'fractions_intro_v1', version: 3)],
    );

    final loaded = await service.loadActivity(lesson);

    expect(loaded.questions, isNotEmpty);
    expect(loaded.summary, isNot('Resumo do catálogo'));
  });
}

class _MalformedRepository implements ContentRepository {
  @override
  Future<Map<String, dynamic>?> fetchActivity(String activityId) async => {
    'id': activityId,
    'activityVersion': 3,
    'questions': [
      {'id': 'broken', 'type': 'unknown'},
    ],
  };

  @override
  Future<ContentManifest?> fetchManifest() async => null;

  @override
  Future<List<Lesson>> findPublishedLessons({required int schoolYear}) async =>
      const [];
}
