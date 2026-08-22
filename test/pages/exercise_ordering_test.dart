import 'package:eureka/pages/lesson/widgets/exercise_ordering.dart';
import 'package:eureka/ui/ui_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const words = ['Uma', 'fração', 'representa', 'partes', 'iguais'];

  testWidgets('monta frase com linhas e remove ao tocar na palavra montada', (
    tester,
  ) async {
    String currentAnswer = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseOrdering(
            words: words,
            primaryColor: UiColor.mathematics,
            onChanged: (answer) => currentAnswer = answer,
          ),
        ),
      ),
    );

    // Toca nas palavras do banco
    await tester.tap(find.text('Uma'));
    await tester.pumpAndSettle();
    expect(currentAnswer, 'Uma');

    await tester.tap(find.text('fração'));
    await tester.pumpAndSettle();
    expect(currentAnswer, 'Uma fração');

    await tester.tap(find.text('representa'));
    await tester.pumpAndSettle();
    expect(currentAnswer, 'Uma fração representa');

    // Toca na palavra 'fração' na montagem para devolvê-la ao banco
    final activeWordChips = find.ancestor(
      of: find.text('fração'),
      matching: find.byType(InkWell),
    );
    await tester.tap(activeWordChips.first);
    await tester.pumpAndSettle();

    expect(currentAnswer, 'Uma representa');
  });

  testWidgets('reordena palavras ao arrastar entre posições', (tester) async {
    String currentAnswer = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseOrdering(
            words: words,
            primaryColor: UiColor.mathematics,
            onChanged: (answer) => currentAnswer = answer,
          ),
        ),
      ),
    );

    // Adiciona 'Uma', 'fração', 'representa'
    await tester.tap(find.text('Uma'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('fração'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('representa'));
    await tester.pumpAndSettle();

    expect(currentAnswer, 'Uma fração representa');

    // Inicia gesto de arrasto (long press + drag) de 'representa' para 'Uma'
    final draggableFinder = find.byType(LongPressDraggable<int>).last;
    final targetFinder = find.byType(DragTarget<int>).first;

    final gesture = await tester.startGesture(
      tester.getCenter(draggableFinder),
    );
    await tester.pump(
      const Duration(milliseconds: 200),
    ); // Aguarda delay do LongPress
    await gesture.moveTo(tester.getCenter(targetFinder));
    await tester.pumpAndSettle();
    await gesture.up();
    await tester.pumpAndSettle();

    // 'representa' foi movido para a primeira posição
    expect(currentAnswer, 'representa Uma fração');
  });
}
