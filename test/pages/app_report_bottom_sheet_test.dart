import 'dart:io';

import 'package:eureka/app/components/app_report_bottom_sheet.dart';
import 'package:eureka/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory tempDirectory;

  setUpAll(() async {
    tempDirectory = Directory.systemTemp.createTempSync('eureka_sheet_test_');
    Hive.init(tempDirectory.path);
    await Hive.openBox<dynamic>('eureka');
  });

  tearDownAll(() async {
    await Hive.close();
    tempDirectory.deleteSync(recursive: true);
  });

  testWidgets('renderiza todas as 6 opções de report, campo de texto e ações', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AppReportBottomSheet.show(
                context,
                lessonId: 'lesson_1',
                lessonTitle: 'Aula 1',
              ),
              child: const Text('Abrir Sheet'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir Sheet'));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.reportProblemTitle), findsOneWidget);
    expect(find.text(AppStrings.reportProblemDescription), findsOneWidget);
    expect(find.text(AppStrings.reportOptionAudioIncorrect), findsOneWidget);
    expect(find.text(AppStrings.reportOptionAudioMissing), findsOneWidget);
    expect(find.text(AppStrings.reportOptionWritingError), findsOneWidget);
    expect(find.text(AppStrings.reportOptionLogicError), findsOneWidget);
    expect(find.text(AppStrings.reportOptionWrongAnswer), findsOneWidget);
    expect(find.text(AppStrings.reportOptionOtherError), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text(AppStrings.send.toUpperCase()), findsOneWidget);

    // Seleciona uma opção e digita texto
    await tester.tap(find.text(AppStrings.reportOptionAudioIncorrect));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Não dá para ouvir nada');
    await tester.pumpAndSettle();

    // Envia o relato
    await tester.ensureVisible(find.text(AppStrings.send.toUpperCase()));
    await tester.tap(find.text(AppStrings.send.toUpperCase()));
    await tester.pumpAndSettle();

    // Sheet fechado e feedback exibido
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text(AppStrings.reportSentSuccess), findsOneWidget);
  });
}
