import 'package:eureka/app/components/app_text_field.dart';
import 'package:eureka/pages/auth/page_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('fornece Material para o campo de texto da autenticação', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: PageAuth(lessons: Future.value(const []))),
    );
    await tester.pump();

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppTextField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
