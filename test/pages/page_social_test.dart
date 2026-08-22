import 'package:eureka/controllers/controller_social.dart';
import 'package:eureka/pages/social/page_social.dart';
import 'package:eureka/repositories/repository_mock_social.dart';
import 'package:eureka/ui/ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renderiza feed e permite curtir publicação', (tester) async {
    final semantics = tester.ensureSemantics();
    final controller = SocialController(MockSocialRepository());
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.dark,
        home: Scaffold(body: PageSocial(controller: controller)),
      ),
    );
    expect(find.text('Novidades'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
    expect(find.byKey(const Key('social_feed')), findsOneWidget);
    expect(find.text('Conquistou Ouro em Frações!'), findsWidgets);
    final heart = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label == 'Curtir publicação de Maria',
    );
    expect(heart, findsOneWidget);
    await tester.tap(heart);
    await tester.pump();
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Descurtir publicação de Maria',
      ),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 150));
    semantics.dispose();
  });
  testWidgets('atalhos de ranking e amigos possuem semântica', (tester) async {
    final semantics = tester.ensureSemantics();
    final controller = SocialController(MockSocialRepository());
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.dark,
        home: Scaffold(body: PageSocial(controller: controller)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'Abrir Ranking',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'Abrir Amigos',
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });
}
