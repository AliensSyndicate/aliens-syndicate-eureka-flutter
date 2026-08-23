import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/pages/home/widgets/widget_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('card de login permanece disponível na Home', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: LoginCard(onTap: () => tapped = true)),
      ),
    );

    expect(find.text(AppStrings.createEurekaAccount), findsOneWidget);
    expect(
      find.text(AppStrings.createEurekaAccountDescription),
      findsOneWidget,
    );

    await tester.tap(find.byType(LoginCard));
    expect(tapped, isTrue);
  });
}
