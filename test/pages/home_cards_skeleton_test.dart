import 'package:eureka/app/components/app_skeleton.dart';
import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/pages/home/widgets/widget_home_cards_skeleton.dart';
import 'package:eureka/ui/ui_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mostra um skeleton para todo o conteúdo da Home', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HomeCardsSkeleton())),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.bySemanticsLabel(AppStrings.loadingContent), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(AppSkeleton), findsNWidgets(6));
    expect(
      tester
          .getSize(find.byKey(const ValueKey('home-feature-skeleton')))
          .height,
      UiCard.continueMinHeight,
    );
    expect(
      find.byKey(const ValueKey('home-subject-skeleton-0')),
      findsOneWidget,
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey('home-subject-skeleton-0')))
          .height,
      UiCard.subjectHeight,
    );
    expect(
      find.byKey(const ValueKey('home-subject-skeleton-2')),
      findsOneWidget,
    );
  });
}
