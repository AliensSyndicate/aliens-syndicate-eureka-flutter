import 'package:eureka/models/model_matching_pair.dart';
import 'package:eureka/pages/lesson/widgets/exercise_matching.dart';
import 'package:eureka/ui/ui_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';

void main() {
  const testPairs = [
    MatchingPair(left: '1/2', right: 'Metade'),
    MatchingPair(left: '1/4', right: 'Um quarto'),
    MatchingPair(left: '3/4', right: 'Três quartos'),
    MatchingPair(left: '1/3', right: 'Um terço'),
    MatchingPair(left: '2/3', right: 'Dois terços'),
  ];

  testWidgets('só mostra correção depois de verificar a resposta', (
    tester,
  ) async {
    var answer = '';

    Widget exercise({bool? answeredCorrect}) => MaterialApp(
      home: Scaffold(
        body: ExerciseMatching(
          pairs: testPairs,
          primaryColor: UiColor.mathematics,
          initialAnswer: answer,
          answeredCorrect: answeredCorrect,
          enabled: answeredCorrect == null,
          onChanged: (value) => answer = value,
        ),
      ),
    );

    await tester.pumpWidget(exercise());
    final wrongRights = [
      'Um quarto',
      'Três quartos',
      'Um terço',
      'Dois terços',
      'Metade',
    ];
    for (var index = 0; index < testPairs.length; index++) {
      await tester.tap(find.text(testPairs[index].left));
      await tester.tap(find.text(wrongRights[index]));
      await tester.pump();
    }

    expect(answer, isNotEmpty);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is HugeIcon &&
            identical(widget.icon, HugeIcons.strokeRoundedCancelCircle),
      ),
      findsNothing,
    );

    await tester.pumpWidget(exercise(answeredCorrect: false));
    await tester.pump();
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is HugeIcon &&
            identical(widget.icon, HugeIcons.strokeRoundedCancelCircle),
      ),
      findsNWidgets(10),
    );
  });
}
