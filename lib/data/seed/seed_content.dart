import '../../enums/question_type.dart';
import '../../enums/subject_type.dart';
import '../../models/model_lesson.dart';
import '../../models/model_matching_pair.dart';
import '../../models/model_question.dart';

final modelMultipleChoiceLesson = Lesson(
  id: 'balanced_food_model',
  title: 'Escolhas para uma alimentação equilibrada',
  summary:
      'Os alimentos fornecem energia e nutrientes para o corpo. Uma alimentação equilibrada combina frutas, verduras, cereais, proteínas e água.',
  subject: SubjectType.science,
  topicId: 'balanced_food',
  questions: [
    _question(
      'balanced_food_1',
      'Qual opção é uma fruta?',
      ['1. Maçã', '2. Arroz', '3. Feijão', '4. Queijo'],
      '1. Maçã',
      'science',
      'balanced_food',
    ),
    _question(
      'balanced_food_2',
      'Qual bebida é a melhor escolha para manter o corpo hidratado?',
      ['1. Refrigerante', '2. Água', '3. Xarope', '4. Energético'],
      '2. Água',
      'science',
      'balanced_food',
    ),
    _question(
      'balanced_food_3',
      'Qual opção apresenta uma verdura ou um legume?',
      ['1. Biscoito', '2. Bala', '3. Cenoura', '4. Sorvete'],
      '3. Cenoura',
      'science',
      'balanced_food',
    ),
    _question(
      'balanced_food_4',
      'Qual refeição combina diferentes grupos de alimentos?',
      [
        '1. Apenas balas',
        '2. Apenas refrigerante',
        '3. Apenas batata frita',
        '4. Arroz, feijão, salada e ovo',
      ],
      '4. Arroz, feijão, salada e ovo',
      'science',
      'balanced_food',
    ),
    _question(
      'balanced_food_5',
      'Qual alimento deve ser consumido com menos frequência por conter muito açúcar?',
      ['1. Banana', '2. Alface', '3. Feijão', '4. Pirulito'],
      '4. Pirulito',
      'science',
      'balanced_food',
    ),
  ],
);

final seedLessons = <Lesson>[
  Lesson(
    id: 'fractions_intro',
    title: 'Frações na prática',
    summary:
        'Imagine uma pizza dividida igualmente entre quatro pessoas. Cada '
        'pessoa recebe 1/4 da pizza.\n\nUma fração representa uma ou mais '
        'partes iguais de um todo. Em 3/4, o denominador 4 mostra em quantas '
        'partes iguais o todo foi dividido. O numerador 3 mostra quantas '
        'partes foram consideradas.\n\nFrações diferentes podem representar '
        'a mesma quantidade. Por exemplo, 1/2 e 2/4 são equivalentes. Para '
        'comparar frações com o mesmo denominador, observe o numerador. Com '
        'denominadores diferentes, transforme as frações em equivalentes ou '
        'imagine as partes do mesmo todo.\n\nLembre-se: as partes precisam ser '
        'iguais e os todos comparados precisam ter o mesmo tamanho.',
    subject: SubjectType.mathematics,
    topicId: 'fractions',
    questions: [
      // ---------------------------------------------------------------------
      // Vitrine temporária: um exercício de cada tipo para validar os
      // componentes. Remover este bloco após o teste.
      // ---------------------------------------------------------------------
      Question(
        id: 'fraction_true_false_1',
        prompt: 'A fração 1/2 é maior que 1/4.',
        type: QuestionType.trueFalse,
        options: const ['Verdadeiro', 'Falso'],
        correctAnswer: 'Verdadeiro',
        explanation:
            'A fração 1/2 equivale a 2/4. Como 2/4 representa duas partes '
            'e 1/4 representa apenas uma parte do mesmo todo, 1/2 é maior.',
        subjectId: 'mathematics',
        topicId: 'fractions',
      ),
      Question(
        id: 'fraction_fill_blank_1',
        prompt: 'Complete a frase com a fração correta.',
        type: QuestionType.fillBlank,
        template:
            'Uma pizza cortada em 4 fatias iguais, com 3 fatias servidas, '
            'corresponde a _ da pizza.',
        options: const ['3/4', '1/4', '4/3', '1/3'],
        correctAnswer: '3/4',
        explanation:
            'A pizza tem 4 fatias iguais e 3 foram servidas. O numerador '
            'registra as 3 partes consideradas; o denominador registra as 4 '
            'partes do todo. A fração é 3/4.',
        subjectId: 'mathematics',
        topicId: 'fractions',
      ),
      Question(
        id: 'fraction_image_choice_1',
        prompt: 'Qual figura representa 3/4?',
        type: QuestionType.imageChoice,
        options: const ['🟦🟦🟦⬜', '🟦⬜⬜⬜', '🟦🟦⬜⬜', '🟦🟦🟦🟦'],
        correctAnswer: '🟦🟦🟦⬜',
        explanation:
            'Em 3/4, o todo tem quatro partes iguais e três delas estão '
            'marcadas. Procure três partes azuis e uma sem preenchimento.',
        subjectId: 'mathematics',
        topicId: 'fractions',
      ),
      Question(
        id: 'fraction_word_completion_1',
        prompt: 'Complete a palavra com as letras que faltam.',
        type: QuestionType.wordCompletion,
        template: 'N_MERAD_R',
        options: const ['U', 'O', 'A', 'E'],
        correctAnswer: 'NUMERADOR',
        explanation:
            'O número acima da barra é o numerador. Ele indica quantas '
            'partes foram consideradas. As letras formam NUMERADOR.',
        subjectId: 'mathematics',
        topicId: 'fractions',
      ),
      Question(
        id: 'fraction_sequencing_1',
        prompt: 'Organize os passos para calcular 1/4 + 2/4.',
        type: QuestionType.sequencing,
        options: const [
          'Confira se os denominadores são iguais',
          'Some os numeradores: 1 + 2 = 3',
          'Mantenha o denominador 4',
          'Escreva o resultado: 3/4',
        ],
        correctAnswer:
            'Confira se os denominadores são iguais | '
            'Some os numeradores: 1 + 2 = 3 | '
            'Mantenha o denominador 4 | '
            'Escreva o resultado: 3/4',
        explanation:
            'Os denominadores já são iguais. Primeiro confirme isso, some '
            'os numeradores, mantenha o denominador 4 e escreva 3/4.',
        subjectId: 'mathematics',
        topicId: 'fractions',
      ),
      Question(
        id: 'fraction_memory_1',
        prompt: 'Jogo da memória: frações equivalentes',
        type: QuestionType.memory,
        options: const [],
        correctAnswer: '__memory_done__',
        explanation:
            'Frações equivalentes representam a mesma quantidade. Verifique '
            'se o numerador e o denominador foram multiplicados pelo mesmo '
            'número, como em 1/2 e 2/4.',
        pairs: const [
          MatchingPair(left: '1/2', right: '2/4'),
          MatchingPair(left: '1/3', right: '2/6'),
          MatchingPair(left: '3/4', right: '6/8'),
          MatchingPair(left: '1/5', right: '2/10'),
          MatchingPair(left: '2/3', right: '4/6'),
          MatchingPair(left: '1/4', right: '3/12'),
        ],
        subjectId: 'mathematics',
        topicId: 'fractions',
      ),
      Question(
        id: 'fraction_essay_1',
        prompt: 'Explique com suas palavras o que é uma fração. Dê um exemplo.',
        type: QuestionType.essay,
        options: const [],
        correctAnswer:
            'Uma fração mostra quantas partes iguais de um todo estamos '
            'usando. Exemplo: 1/2 é metade de uma pizza.',
        explanation:
            'Uma boa explicação mostra que o todo foi dividido em partes '
            'iguais e quantas partes foram consideradas. Use um exemplo, '
            'como 1/2 de uma pizza.',
        subjectId: 'mathematics',
        topicId: 'fractions',
      ),
      // Exercício de ordenação: frase explicativa sobre frações
      _orderingQuestion(
        'fraction_ordering_1',
        'Ordene as palavras para formar a frase:',
        ['Uma', 'fração', 'representa', 'partes', 'iguais', 'de um', 'todo'],
        'Uma fração representa partes iguais de um todo',
        'mathematics',
        'fractions',
        explanation:
            'Comece com “Uma fração representa” e complete com a ideia '
            'essencial: “partes iguais de um todo”.',
      ),
      // Exercício de ligação: fração ↔ nome por extenso
      _matchingQuestion(
        'fraction_matching_1',
        'Ligue cada fração ao seu nome',
        [
          MatchingPair(left: '1/2', right: 'Metade'),
          MatchingPair(left: '1/4', right: 'Um quarto'),
          MatchingPair(left: '3/4', right: 'Três quartos'),
          MatchingPair(left: '1/3', right: 'Um terço'),
          MatchingPair(left: '2/3', right: 'Dois terços'),
        ],
        'mathematics',
        'fractions',
        explanation:
            'Leia o numerador como a quantidade de partes e o denominador '
            'como o nome dessas partes. Assim, 1/2 é metade; denominador 3 '
            'indica terços e denominador 4 indica quartos.',
      ),
      _question(
        'fraction_1',
        'Qual fração representa metade?',
        ['1/2', '1/3', '2/3', '3/3'],
        '1/2',
        'mathematics',
        'fractions',
        explanation:
            'Metade é uma de duas partes iguais. Por isso, é representada '
            'por 1/2.',
      ),
      Question(
        id: 'fraction_text_input_1',
        prompt: 'Escreva a fração que representa metade.',
        type: QuestionType.textInput,
        options: const [],
        correctAnswer: '1/2',
        explanation:
            'Metade significa uma de duas partes iguais. Escrevemos 1 no '
            'numerador e 2 no denominador: 1/2.',
        subjectId: 'mathematics',
        topicId: 'fractions',
      ),
    ],
  ),
  Lesson(
    id: 'text_genres',
    title: 'Gêneros textuais',
    summary:
        'Cada texto tem uma intenção: informar, ensinar, divertir ou convencer.',
    subject: SubjectType.portuguese,
    topicId: 'genres',
    questions: [
      _question(
        'genre_1',
        'Qual texto ensina a preparar um alimento?',
        ['Receita', 'Poema', 'Notícia', 'Fábula'],
        'Receita',
        'portuguese',
        'genres',
      ),
      _question(
        'genre_2',
        'Qual gênero informa um acontecimento recente?',
        ['Notícia', 'Fábula', 'Bilhete', 'Conto'],
        'Notícia',
        'portuguese',
        'genres',
      ),
      _question(
        'genre_3',
        'Qual texto costuma ter versos e estrofes?',
        ['Poema', 'Manual', 'Reportagem', 'Receita'],
        'Poema',
        'portuguese',
        'genres',
      ),
      _question(
        'genre_4',
        'Qual gênero apresenta instruções de uso?',
        ['Manual', 'Conto', 'Entrevista', 'Notícia'],
        'Manual',
        'portuguese',
        'genres',
      ),
      _question(
        'genre_5',
        'Qual texto é usado para deixar um recado curto?',
        ['Bilhete', 'Verbete', 'Crônica', 'Poema'],
        'Bilhete',
        'portuguese',
        'genres',
      ),
      _question(
        'genre_6',
        'Qual gênero registra perguntas e respostas?',
        ['Entrevista', 'Receita', 'Poema', 'Conto'],
        'Entrevista',
        'portuguese',
        'genres',
      ),
      _question(
        'genre_7',
        'Qual texto apresenta o significado de uma palavra?',
        ['Verbete', 'Notícia', 'Convite', 'Manual'],
        'Verbete',
        'portuguese',
        'genres',
      ),
      _question(
        'genre_8',
        'Qual gênero chama pessoas para um evento?',
        ['Convite', 'Reportagem', 'Fábula', 'Verbete'],
        'Convite',
        'portuguese',
        'genres',
      ),
      _question(
        'genre_9',
        'Qual texto narra uma história curta com personagens?',
        ['Conto', 'Manual', 'Verbete', 'Bilhete'],
        'Conto',
        'portuguese',
        'genres',
      ),
      _question(
        'genre_10',
        'Qual gênero aprofunda informações sobre um tema?',
        ['Reportagem', 'Bilhete', 'Receita', 'Poema'],
        'Reportagem',
        'portuguese',
        'genres',
      ),
    ],
  ),
  Lesson(
    id: 'water_cycle',
    title: 'O ciclo da água',
    summary: 'A água circula pela natureza em transformações contínuas.',
    subject: SubjectType.science,
    topicId: 'water',
    questions: [
      _question(
        'water_1',
        'Como se chama a passagem da água líquida para vapor?',
        ['Evaporação', 'Precipitação', 'Solidificação', 'Condensação'],
        'Evaporação',
        'science',
        'water',
      ),
      _question(
        'water_2',
        'Como se chama a formação de gotículas nas nuvens?',
        ['Condensação', 'Fusão', 'Infiltração', 'Evaporação'],
        'Condensação',
        'science',
        'water',
      ),
      _question(
        'water_3',
        'A queda de água das nuvens é chamada de:',
        ['Precipitação', 'Evaporação', 'Transpiração', 'Infiltração'],
        'Precipitação',
        'science',
        'water',
      ),
      _question(
        'water_4',
        'Qual fonte de energia impulsiona a evaporação?',
        ['Sol', 'Lua', 'Solo', 'Vento'],
        'Sol',
        'science',
        'water',
      ),
      _question(
        'water_5',
        'Quando a água entra no solo, ocorre:',
        ['Infiltração', 'Condensação', 'Ebulição', 'Precipitação'],
        'Infiltração',
        'science',
        'water',
      ),
      _question(
        'water_6',
        'Em qual estado está o vapor de água?',
        ['Gasoso', 'Sólido', 'Líquido', 'Plasma'],
        'Gasoso',
        'science',
        'water',
      ),
      _question(
        'water_7',
        'O gelo é água em estado:',
        ['Sólido', 'Gasoso', 'Líquido', 'Supercrítico'],
        'Sólido',
        'science',
        'water',
      ),
      _question(
        'water_8',
        'Rios e lagos participam do ciclo como locais de:',
        [
          'Acúmulo de água',
          'Criação de água',
          'Desaparecimento de água',
          'Transformação em gás',
        ],
        'Acúmulo de água',
        'science',
        'water',
      ),
      _question(
        'water_9',
        'As plantas liberam vapor de água principalmente pela:',
        ['Transpiração', 'Precipitação', 'Solidificação', 'Infiltração'],
        'Transpiração',
        'science',
        'water',
      ),
      _question(
        'water_10',
        'Economizar água ajuda a:',
        [
          'Preservar esse recurso',
          'Interromper o ciclo',
          'Impedir a chuva',
          'Aumentar a evaporação',
        ],
        'Preservar esse recurso',
        'science',
        'water',
      ),
    ],
  ),
  modelMultipleChoiceLesson,
];

Question _question(
  String id,
  String prompt,
  List<String> options,
  String correctAnswer,
  String subjectId,
  String topicId, {
  String explanation = '',
}) => Question(
  id: id,
  prompt: prompt,
  type: QuestionType.multipleChoice,
  options: options,
  correctAnswer: correctAnswer,
  subjectId: subjectId,
  topicId: topicId,
  explanation: explanation,
);

/// Cria uma questão do tipo ligação com 5 pares.
Question _matchingQuestion(
  String id,
  String prompt,
  List<MatchingPair> pairs,
  String subjectId,
  String topicId, {
  String explanation = '',
}) => Question(
  id: id,
  prompt: prompt,
  type: QuestionType.matching,
  options: const [],
  // Sentinela: a questão é marcada correta quando todos os pares são ligados.
  correctAnswer: '__matching_done__',
  subjectId: subjectId,
  topicId: topicId,
  pairs: pairs,
  explanation: explanation,
);

/// Cria uma questão de ordenação de frase.
Question _orderingQuestion(
  String id,
  String prompt,
  List<String> words,
  String correctAnswer,
  String subjectId,
  String topicId, {
  String explanation = '',
}) => Question(
  id: id,
  prompt: prompt,
  type: QuestionType.ordering,
  options: words,
  correctAnswer: correctAnswer,
  subjectId: subjectId,
  topicId: topicId,
  explanation: explanation,
);
