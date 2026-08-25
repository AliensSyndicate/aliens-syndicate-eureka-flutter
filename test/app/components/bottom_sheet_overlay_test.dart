import 'package:eureka/app/components/app_bottom_sheet.dart';
import 'package:eureka/app/components/show_school_year_sheet.dart';
import 'package:eureka/ui/ui_bottom_sheet.dart';
import 'package:eureka/ui/ui_color.dart';
import 'package:eureka/ui/ui_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('animação de abertura dos sheets usa velocidade reduzida', () {
    expect(UiBottomSheet.openDuration, const Duration(milliseconds: 400));
    expect(UiBottomSheet.closeDuration, const Duration(milliseconds: 300));
  });

  testWidgets('AppBottomSheet usa overlay totalmente transparente', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => AppBottomSheet.show<void>(
              context,
              title: 'Título',
              content: const Text('Conteúdo'),
            ),
            child: const Text('Abrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(UiBottomSheet.overlayColor, const Color(0x00000000));
    expect(_modalBarrier(tester).color, isNull);
    _expectNavigationBorder(tester);
  });

  testWidgets('seletor de turma usa overlay totalmente transparente', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSchoolYearSheet(
              context,
              currentYear: 5,
              availableYears: const [5],
            ),
            child: const Text('Abrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(UiBottomSheet.overlayColor, const Color(0x00000000));
    expect(_modalBarrier(tester).color, isNull);
    _expectNavigationBorder(tester);
  });
}

ModalBarrier _modalBarrier(WidgetTester tester) => tester.widget<ModalBarrier>(
  find.byWidgetPredicate(
    (widget) => widget is ModalBarrier && widget.dismissible,
  ),
);

void _expectNavigationBorder(WidgetTester tester) {
  final decoratedBoxes = tester
      .widgetList<DecoratedBox>(find.byType(DecoratedBox))
      .where((widget) => widget.decoration is BoxDecoration);
  final border = decoratedBoxes
      .map((widget) => (widget.decoration as BoxDecoration).border)
      .whereType<Border>()
      .firstWhere(
        (border) =>
            border.top.color == UiColor.outline &&
            border.top.width == UiNavigation.topBorderWidth,
      );

  expect(border.left, BorderSide.none);
  expect(border.right, BorderSide.none);
  expect(border.bottom, BorderSide.none);
}
