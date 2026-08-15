import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/pages/home/widgets/widget_home_cards_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mostra skeletons dos cards durante o carregamento', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HomeCardsSkeleton())),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.bySemanticsLabel(AppStrings.loadingContent), findsOneWidget);
    expect(find.byKey(const ValueKey('home-subject-skeleton-0')), findsOne);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();

    expect(
      find.byKey(
        const ValueKey(
          'home-subject-skeleton-${HomeCardsSkeleton.subjectCount - 1}',
        ),
      ),
      findsOne,
    );
  });
}
