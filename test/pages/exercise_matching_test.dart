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

  testWidgets('opções não somem e erro trava em vermelho', (tester) async {
    bool? completedAllCorrect;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseMatching(
            pairs: testPairs,
            primaryColor: UiColor.mathematics,
            onCompleted: (allCorrect) => completedAllCorrect = allCorrect,
          ),
        ),
      ),
    );

    // Seleciona um par correto: 1/2 e Metade
    await tester.tap(find.text('1/2'));
    await tester.pump();
    await tester.tap(find.text('Metade'));
    await tester.pumpAndSettle();

    // As opções continuam visíveis na tela
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('Metade'), findsOneWidget);

    // Seleciona um par incorreto: 1/4 e Dois terços
    await tester.tap(find.text('1/4'));
    await tester.pump();
    await tester.tap(find.text('Dois terços'));
    await tester.pumpAndSettle();

    // Opções incorretas continuam na tela e com ícone de erro
    expect(find.text('1/4'), findsOneWidget);
    expect(find.text('Dois terços'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is HugeIcon &&
            identical(widget.icon, HugeIcons.strokeRoundedCancelCircle),
      ),
      findsNWidgets(2),
    );

    // Clicar novamente em uma opção travada não altera estado
    await tester.tap(find.text('1/4'));
    await tester.pump();
    expect(completedAllCorrect, isNull);
  });
}
