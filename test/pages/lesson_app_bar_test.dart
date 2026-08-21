import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/pages/lesson/widgets/widget_lesson_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe somente o botao de fechar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(appBar: LessonAppBar(onClose: () {})),
      ),
    );
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, isNotNull);
    expect(find.byTooltip(AppStrings.closeActivity), findsOneWidget);
    expect(find.byTooltip(AppStrings.reportError), findsNothing);
    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
