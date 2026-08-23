import 'package:eureka/app/components/app_home_bar.dart';
import 'package:eureka/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'renderiza AppHomeBar com moedas na esquerda, logo no centro e turma na direita',
    (tester) async {
      var xpTapped = false;
      var schoolYearTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppHomeBar(
              xp: 150,
              schoolYear: 5,
              onXpTap: () => xpTapped = true,
              onSchoolYearTap: () => schoolYearTapped = true,
            ),
          ),
        ),
      );

      final screenWidth = tester.getSize(find.byType(Scaffold)).width;

      final xpFinder = find.text('150');
      final yearFinder = find.text(AppStrings.schoolYear(5));

      expect(xpFinder, findsOneWidget);
      expect(yearFinder, findsOneWidget);

      final xpCenter = tester.getCenter(xpFinder);
      final yearCenter = tester.getCenter(yearFinder);

      // Moedas na esquerda, turma na direita
      expect(xpCenter.dx, lessThan(screenWidth / 2));
      expect(yearCenter.dx, greaterThan(screenWidth / 2));

      await tester.tap(xpFinder);
      expect(xpTapped, isTrue);

      await tester.tap(yearFinder);
      expect(schoolYearTapped, isTrue);
    },
  );
}
