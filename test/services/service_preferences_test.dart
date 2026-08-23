import 'dart:io';

import 'package:eureka/data/local/hive_preferences_repository.dart';
import 'package:eureka/services/service_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  test('persiste preferências de narração e movimento', () async {
    final directory = await Directory.systemTemp.createTemp('preferences');
    Hive.init(directory.path);
    final box = await Hive.openBox<dynamic>('preferences');
    addTearDown(() async {
      await Hive.close();
      await directory.delete(recursive: true);
    });
    final service = PreferencesService(HivePreferencesRepository(box));

    await service.setNarrationEnabled(false);
    await service.setReducedMotion(true);

    expect(service.load().narrationEnabled, isFalse);
    expect(service.load().reducedMotion, isTrue);
  });
}
