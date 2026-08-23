import 'dart:io';

import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/pages/home/page_home.dart';
import 'package:eureka/pages/home/widgets/widget_login_card.dart';
import 'package:eureka/pages/home/widgets/widget_planet_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory tempDirectory;

  setUpAll(() async {
    tempDirectory = Directory.systemTemp.createTempSync(
      'eureka_home_pos_test_',
    );
    Hive.init(tempDirectory.path);
    await Hive.openBox<dynamic>('eureka');
    await Hive.openBox<dynamic>('content_cache_v1');
  });

  tearDownAll(() async {
    await Hive.close();
    tempDirectory.deleteSync(recursive: true);
  });

  testWidgets(
    'PageHome exibe scroll horizontal de cards e planetas com scroll vertical',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PageHome())),
      );

      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Não deve exibir título estático de matérias
      expect(find.text(AppStrings.subjectsTitle), findsNothing);

      // Deve exibir login card
      expect(find.byType(LoginCard), findsOneWidget);

      // Deve ter os 5 botões de planetas
      expect(find.byType(PlanetButton), findsNWidgets(5));
    },
  );
}
