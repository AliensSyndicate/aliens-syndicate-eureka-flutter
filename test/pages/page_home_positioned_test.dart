import 'dart:io';

import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/pages/home/page_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory tempDirectory;

  setUpAll(() async {
    tempDirectory = Directory.systemTemp.createTempSync('eureka_home_pos_test_');
    Hive.init(tempDirectory.path);
    await Hive.openBox<dynamic>('eureka');
    await Hive.openBox<dynamic>('content_cache_v1');
  });

  tearDownAll(() async {
    await Hive.close();
    tempDirectory.deleteSync(recursive: true);
  });

  testWidgets(
    'PageHome posiciona as 5 ilhas/planetas de matérias com Stack e Positioned',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PageHome(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Não deve exibir título de matérias nem cards escondidos
      expect(find.text(AppStrings.subjectsTitle), findsNothing);
      expect(find.text(AppStrings.recommendedForYou), findsNothing);
      expect(find.text(AppStrings.continueWhereStopped), findsNothing);

      // Deve ter Positioned widgets para as matérias
      expect(find.byType(Positioned), findsNWidgets(5));

      // Deve encontrar as 5 imagens das matérias .png
      expect(find.byType(Image), findsNWidgets(5));
    },
  );
}
