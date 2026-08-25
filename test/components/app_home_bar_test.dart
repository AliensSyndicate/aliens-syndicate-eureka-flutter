import 'package:eureka/pages/home/widgets/widget_home_universe_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renderiza o núcleo rolável com XP, logo e ano', (tester) async {
    var xpTapped = false;
    var schoolYearTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeUniverseHeader(
            xp: 150,
            schoolYear: 5,
            onXpTap: () => xpTapped = true,
            onSchoolYearTap: () => schoolYearTapped = true,
          ),
        ),
      ),
    );

    final screenWidth = tester.getSize(find.byType(Scaffold)).width;

    final xpFinder = find.text('150 xp');
    final yearFinder = find.text('5° ano');

    expect(xpFinder, findsOneWidget);
    expect(yearFinder, findsOneWidget);
    expect(find.byKey(const ValueKey('home-universe-logo')), findsOneWidget);

    final xpCenter = tester.getCenter(xpFinder);
    final yearCenter = tester.getCenter(yearFinder);

    // Moedas na esquerda, turma na direita
    expect(xpCenter.dx, lessThan(screenWidth / 2));
    expect(yearCenter.dx, greaterThan(screenWidth / 2));

    await tester.tap(xpFinder);
    expect(xpTapped, isTrue);

    await tester.tap(yearFinder);
    expect(schoolYearTapped, isTrue);
  });
}
