import 'dart:io';

import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/pages/home/page_home.dart';
import 'package:eureka/pages/home/widgets/widget_action_planet_button.dart';
import 'package:eureka/pages/home/widgets/widget_continue_learning_card.dart';
import 'package:eureka/pages/home/widgets/widget_curved_text.dart';
import 'package:eureka/pages/home/widgets/widget_login_card.dart';
import 'package:eureka/pages/home/widgets/widget_planet_button.dart';
import 'package:eureka/pages/subject/page_subject.dart';
import 'package:eureka/pages/subject/widgets/widget_subject_sheet_header.dart';
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
      expect(find.byType(ActionPlanetButton), findsAtLeastNWidgets(1));
      expect(
        tester
            .widgetList<ActionPlanetButton>(find.byType(ActionPlanetButton))
            .map((button) => button.size),
        everyElement(lessThan(100)),
      );
      expect(
        find.descendant(
          of: find.byType(LoginCard),
          matching: find.byType(CurvedText),
        ),
        findsOneWidget,
      );

      // Deve mostrar somente as matérias habilitadas para o ano letivo.
      expect(find.byType(PlanetButton), findsNWidgets(5));
      final planets = tester.widgetList<PlanetButton>(
        find.byType(PlanetButton),
      );
      expect(
        planets.map((planet) => planet.progressText),
        everyElement(matches(RegExp(r'^\d+ de \d{2} aulas\.$'))),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('home-planets-orbit'))).height,
        lessThan(1040),
      );

      final actionTopBefore = tester.getTopLeft(find.byType(LoginCard)).dy;
      final planetTopBefore = tester
          .getTopLeft(find.byType(PlanetButton).first)
          .dy;
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -120),
      );
      await tester.pump();

      expect(
        tester.getTopLeft(find.byType(LoginCard)).dy,
        lessThan(actionTopBefore),
      );
      expect(
        tester.getTopLeft(find.byType(PlanetButton).first).dy,
        lessThan(planetTopBefore),
      );

      await tester.tap(find.byType(ContinueLearningCard));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text(AppStrings.continueTitle), findsOneWidget);
    },
  );

  testWidgets('abre a matéria em AppBottomSheet', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PageHome())),
    );

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    await tester.tap(find.byType(PlanetButton).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(SubjectSheet), findsOneWidget);
    expect(find.byType(SubjectSheetHeader), findsOneWidget);
    expect(find.byKey(const ValueKey('subject-header-planet')), findsOneWidget);
    expect(
      tester
          .getSize(
            find.byKey(const ValueKey('subject-sheet-header-background')),
          )
          .width,
      tester.getSize(find.byType(BottomSheet)).width,
    );

    await tester.drag(find.byType(BottomSheet), const Offset(0, 80));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(BottomSheet), findsOneWidget);

    await tester.tap(find.byTooltip(AppStrings.back));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(BottomSheet), findsNothing);
  });
}
