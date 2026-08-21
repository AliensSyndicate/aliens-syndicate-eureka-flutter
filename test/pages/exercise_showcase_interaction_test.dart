import 'package:eureka/models/model_matching_pair.dart';
import 'package:eureka/pages/lesson/widgets/exercise_fill_blank.dart';
import 'package:eureka/pages/lesson/widgets/exercise_memory.dart';
import 'package:eureka/pages/lesson/widgets/exercise_sequencing.dart';
import 'package:eureka/pages/lesson/widgets/exercise_word_completion.dart';
import 'package:eureka/ui/ui_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';

Future<void> host(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  testWidgets('lacuna reporta a opção tocada', (tester) async {
    String? answer;
    await host(
      tester,
      ExerciseFillBlank(
        sentence: 'Três de quatro fatias equivalem a _ da pizza.',
        options: const ['3/4', '1/4'],
        currentAnswer: '',
        primaryColor: UiColor.mathematics,
        onOptionSelected: (value) => answer = value,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('fill-blank-3/4')));
    expect(answer, '3/4');
  });

  testWidgets('completar palavra só envia a palavra inteira', (tester) async {
    final reported = <String>[];
    await host(
      tester,
      ExerciseWordCompletion(
        template: 'N_MERAD_R',
        letters: const ['U', 'O', 'A', 'E'],
        primaryColor: UiColor.mathematics,
        onChanged: reported.add,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('word-letter-0'))); // U
    await tester.pump();
    expect(reported.last, isEmpty, reason: 'ainda falta uma lacuna');

    await tester.tap(find.byKey(const ValueKey('word-letter-1'))); // O
    await tester.pump();
    expect(reported.last, 'NUMERADOR');
  });

  testWidgets('ordenação publica a ordem inicial e a reordenada', (
    tester,
  ) async {
    final reported = <String>[];
    const items = ['Passo A', 'Passo B', 'Passo C'];
    await host(
      tester,
      ExerciseSequencing(
        items: items,
        primaryColor: UiColor.mathematics,
        onChanged: reported.add,
      ),
    );
    await tester.pump();

    expect(reported, hasLength(1));
    expect(
      reported.single.split(ExerciseSequencing.separator).toSet(),
      items.toSet(),
    );

    final handle = find
        .descendant(
          of: find.byType(ReorderableDragStartListener),
          matching: find.byType(HugeIcon),
        )
        .first;
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(const Duration(milliseconds: 200));
    await gesture.moveBy(const Offset(0, 120));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(reported.length, greaterThan(1));
    expect(reported.last, isNot(reported.first));
  });

  testWidgets('memória revela o par correto e conclui', (tester) async {
    var completed = false;
    await host(
      tester,
      ExerciseMemory(
        pairs: const [
          MatchingPair(left: '1/2', right: '2/4'),
          MatchingPair(left: '1/3', right: '2/6'),
        ],
        primaryColor: UiColor.mathematics,
        onCompleted: (_) => completed = true,
      ),
    );

    // As cartas nascem embaralhadas e viradas: percorre todas as combinações.
    for (var first = 0; first < 4 && !completed; first++) {
      for (var second = first + 1; second < 4 && !completed; second++) {
        for (final index in [first, second]) {
          await tester.tap(find.byKey(ValueKey('memory-card-$index')));
          await tester.pumpAndSettle();
        }
        await tester.pump(const Duration(milliseconds: 800));
        await tester.pumpAndSettle();
      }
    }

    expect(completed, isTrue);
    expect(find.text('2/2'), findsOneWidget, reason: 'contador de pares');
  });

  testWidgets('memória finalizada mantém todas as cartas viradas', (
    tester,
  ) async {
    await host(
      tester,
      ExerciseMemory(
        pairs: const [
          MatchingPair(left: '1/2', right: '2/4'),
          MatchingPair(left: '1/3', right: '2/6'),
        ],
        primaryColor: UiColor.mathematics,
        enabled: false,
        revealAll: true,
        onCompleted: (_) {},
      ),
    );
    await tester.pumpAndSettle();

    for (final label in ['1/2', '2/4', '1/3', '2/6']) {
      expect(find.text(label), findsOneWidget);
    }
  });
}
