import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/pages/lesson/widgets/widget_lesson_app_bar.dart';
import 'package:eureka/services/service_lesson_timer.dart';
import 'package:eureka/ui/ui_color.dart';
import 'package:eureka/ui/ui_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe fechar, tempo crescente e paginacao', (tester) async {
    final remainingTime = ValueNotifier(
      LessonTimerService.initialDuration -
          const Duration(minutes: 1, seconds: 23),
    );
    addTearDown(remainingTime.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: LessonAppBar(
            remainingTime: remainingTime,
            lessonDuration: LessonTimerService.initialDuration,
            currentPage: 1,
            totalPages: 7,
          ),
        ),
      ),
    );

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, UiColor.background);
    expect(appBar.systemOverlayStyle?.statusBarColor, UiColor.background);
    expect(find.byTooltip(AppStrings.closeActivity), findsOneWidget);
    expect(find.text('01m23s'), findsOneWidget);
    expect(find.text('pag. 01/07'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(
      tester.getSize(find.byType(IconButton)),
      const Size.square(UiSize.touchTarget),
    );
  });

  testWidgets('atualiza o tempo decorrido e a pagina atual', (tester) async {
    final remainingTime = ValueNotifier(LessonTimerService.initialDuration);
    addTearDown(remainingTime.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: LessonAppBar(
            remainingTime: remainingTime,
            lessonDuration: LessonTimerService.initialDuration,
            currentPage: 3,
            totalPages: 7,
          ),
        ),
      ),
    );

    expect(find.text('00m00s'), findsOneWidget);
    expect(find.text('pag. 03/07'), findsOneWidget);

    remainingTime.value -= const Duration(seconds: 1);
    await tester.pump();

    expect(find.text('00m01s'), findsOneWidget);
  });
}
