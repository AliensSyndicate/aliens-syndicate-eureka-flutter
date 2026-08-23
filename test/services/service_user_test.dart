import 'dart:io';

import 'package:eureka/data/local/hive_user_repository.dart';
import 'package:eureka/models/model_user.dart';
import 'package:eureka/services/service_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory tempDirectory;
  late Box<dynamic> box;
  late UserService service;

  setUpAll(() async {
    tempDirectory = Directory.systemTemp.createTempSync('eureka_user_');
    Hive.init(tempDirectory.path);
    box = await Hive.openBox<dynamic>('user_service');
  });

  tearDownAll(() async {
    await Hive.close();
    tempDirectory.deleteSync(recursive: true);
  });

  setUp(() async {
    await box.clear();
    service = UserService(HiveUserRepository(box));
  });

  test('usuário temporário não está autenticado', () {
    expect(service.isAuthenticated, isFalse);
  });

  test('usuário persistido não temporário está autenticado', () async {
    const user = AppUser(
      id: 'authenticated_user',
      displayName: 'Estudante',
      schoolYear: 5,
      isTemporary: false,
    );
    await box.put('current_user', user.toMap());

    expect(service.isAuthenticated, isTrue);
  });
}
