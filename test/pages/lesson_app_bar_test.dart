import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/pages/lesson/widgets/widget_lesson_app_bar.dart';
import 'package:eureka/ui/ui_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe somente fechar e reportar com alvos acessiveis', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: LessonAppBar(
            onClose: () {},
            onReport: () {},
            indicators: const SizedBox(key: ValueKey('indicators')),
          ),
        ),
      ),
    );
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, Colors.transparent);
    expect(appBar.surfaceTintColor, Colors.transparent);
    expect(appBar.forceMaterialTransparency, isTrue);
    expect(find.byTooltip(AppStrings.closeActivity), findsOneWidget);
    expect(find.byTooltip(AppStrings.reportError), findsOneWidget);
    expect(find.byKey(const ValueKey('indicators')), findsOneWidget);
    expect(find.byType(IconButton), findsNWidgets(2));
    for (final element in find.byType(IconButton).evaluate()) {
      expect(
        tester.getSize(find.byWidget(element.widget)),
        const Size.square(UiSize.touchTarget),
      );
    }
    final closeRect = tester.getRect(find.byTooltip(AppStrings.closeActivity));
    final reportRect = tester.getRect(find.byTooltip(AppStrings.reportError));
    final screenWidth =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;
    expect(closeRect.left, screenWidth - reportRect.right);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
