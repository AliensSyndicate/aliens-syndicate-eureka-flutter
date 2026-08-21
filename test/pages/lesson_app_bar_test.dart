import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/pages/lesson/widgets/widget_lesson_app_bar.dart';
import 'package:eureka/ui/ui_color.dart';
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
          appBar: LessonAppBar(onClose: () {}, onReport: () {}),
        ),
      ),
    );
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, UiColor.background);
    expect(find.byTooltip(AppStrings.closeActivity), findsOneWidget);
    expect(find.byTooltip(AppStrings.reportError), findsOneWidget);
    expect(find.byType(IconButton), findsNWidgets(2));
    for (final element in find.byType(IconButton).evaluate()) {
      expect(
        tester.getSize(find.byWidget(element.widget)),
        const Size.square(UiSize.touchTarget),
      );
    }
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
