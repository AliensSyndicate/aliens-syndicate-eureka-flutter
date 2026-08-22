import 'package:eureka/data/codecs/content_activity_codec.dart';
import 'package:eureka/enums/question_type.dart';
import 'package:eureka/models/model_question.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decodifica metadados e separa 5 questões práticas de 3 extras', () {
    final decoded = ContentActivityCodec.decode({
      'summary': 'Resumo',
      'unit': 'Números',
      'topic': 'Frações',
      'short_description': 'Uma introdução visual.',
      'bncc_codes': ['EF05MA03'],
      'skills': ['Comparar frações'],
      'learning_objectives': ['Reconhecer frações equivalentes'],
      'estimated_minutes': 12,
      'content_pages': [
        {
          'page': 1,
          'type': 'hook',
          'title': 'Uma pizza',
          'text': 'Como dividir igualmente?',
          'visual_description': 'Pizza dividida em quatro partes.',
          'key_concept': 'Partes iguais',
        },
      ],
      'practice_exercises': [
        for (var index = 0; index < 5; index++) _exercise(index, 'practice'),
      ],
      'extra_exercises': [
        for (var index = 5; index < 8; index++)
          _exercise(index, 'simulator_explore'),
      ],
    });

    expect(decoded, isNotNull);
    expect(decoded!.questions, hasLength(8));
    expect(
      decoded.questions.where((item) => item.usage == QuestionUsage.practice),
      hasLength(5),
    );
    expect(
      decoded.questions.where(
        (item) => item.usage == QuestionUsage.simulatorExplore,
      ),
      hasLength(3),
    );
    expect(decoded.contentPages.single.keyConcept, 'Partes iguais');
    expect(decoded.bnccCodes, ['EF05MA03']);
  });

  test('aceita nomes snake_case e converte option_id no texto da opção', () {
    final decoded = ContentActivityCodec.decode({
      'questions': _completeQuestionSet(),
    });

    final question = decoded!.questions[1];
    expect(question.type, QuestionType.multipleChoice);
    expect(question.prompt, 'Quanto é 1 + 1?');
    expect(question.instruction, 'Escolha uma alternativa.');
    expect(question.options, ['1', '2', '3', '4']);
    expect(question.correctAnswer, '2');
    expect(question.difficulty, 2);
  });

  test(
    'rejeita atividade quando questões inválidas quebram o contrato 5 + 3',
    () {
      final decoded = ContentActivityCodec.decode({
        'questions': [
          {..._exercise(1, 'practice'), 'type': 'unknown_type'},
          {..._exercise(2, 'practice'), 'statement': ''},
        ],
      });

      expect(decoded, isNull);
    },
  );

  test('sequencing preserva o separador usado pelo componente', () {
    final decoded = ContentActivityCodec.decode({
      'subject_id': 'science',
      'topic_id': 'water_cycle',
      'questions': _completeQuestionSet(
        replacementIndex: 5,
        replacement: {
          'id': 'cycle_order',
          'usage': 'simulator_explore',
          'type': 'sequencing',
          'difficulty': 'easy',
          'statement': 'Ordene as etapas.',
          'instruction': 'Arraste os itens.',
          'parameters': {
            'items': [
              {'id': 'a', 'text': 'Evaporação'},
              {'id': 'b', 'text': 'Condensação'},
              {'id': 'c', 'text': 'Precipitação'},
              {'id': 'd', 'text': 'Infiltração'},
            ],
          },
          'correct_answer': {
            'ordered_ids': ['a', 'b', 'c', 'd'],
          },
          'correct_answer_explanation': 'Essa é a sequência do ciclo.',
        },
      ),
    });

    expect(
      decoded!.questions
          .singleWhere((item) => item.id == 'cycle_order')
          .correctAnswer,
      'Evaporação | Condensação | Precipitação | Infiltração',
    );
  });

  test('rejeita distribuição diferente de 5 práticas e 3 extras', () {
    final questions = _completeQuestionSet();
    questions[4] = {...questions[4], 'usage': 'simulator_explore'};

    expect(ContentActivityCodec.decode({'questions': questions}), isNull);
  });
}

List<Map<String, dynamic>> _completeQuestionSet({
  int? replacementIndex,
  Map<String, dynamic>? replacement,
}) => [
  for (var index = 0; index < 8; index++)
    if (index == replacementIndex)
      replacement!
    else
      _exercise(index, index < 5 ? 'practice' : 'simulator_explore'),
];

Map<String, dynamic> _exercise(int index, String usage) => {
  'id': 'question_$index',
  'usage': usage,
  'type': 'multiple_choice',
  'difficulty': 'medium',
  'statement': 'Quanto é 1 + 1?',
  'instruction': 'Escolha uma alternativa.',
  'parameters': {
    'options': [
      {'id': 'a', 'text': '1'},
      {'id': 'b', 'text': '2'},
      {'id': 'c', 'text': '3'},
      {'id': 'd', 'text': '4'},
    ],
    'shuffle': true,
  },
  'correct_answer': {'option_id': 'b'},
  'correct_answer_explanation': 'Somando uma unidade a outra, obtemos 2.',
  'subject_id': 'mathematics',
  'topic_id': 'fractions',
  'version': 1,
};
