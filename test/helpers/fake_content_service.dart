import 'dart:io';

import 'package:eureka/data/local/hive_content_activity_cache.dart';
import 'package:eureka/data/local/hive_content_manifest_cache.dart';
import 'package:eureka/services/service_content.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// ContentService inicializado com seed data, sem Hive real.
/// Usado nos testes do Explorar para ter dados buscáveis.
class FakeContentService extends ContentService {
  FakeContentService._internal(
    super.remote,
    super.manifestCache,
    super.activityCache,
  );

  static Box<dynamic>? _box;
  static Directory? _dir;

  factory FakeContentService() {
    if (_box == null) {
      throw StateError('FakeContentService.setup() not called in setUpAll');
    }
    return FakeContentService._internal(
      null,
      HiveContentManifestCache(_box!),
      HiveContentActivityCache(_box!),
    );
  }

  /// Deve ser chamado em `setUpAll` do test.
  static Future<void> setup() async {
    _dir = Directory.systemTemp.createTempSync('eureka_explore_test_');
    Hive.init(_dir!.path);
    _box = await Hive.openBox<dynamic>('explore_test');
  }

  /// Deve ser chamado em `tearDownAll` do test.
  static Future<void> teardown() async {
    await Hive.close();
    _dir?.deleteSync(recursive: true);
  }
}
