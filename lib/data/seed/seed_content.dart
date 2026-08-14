import '../../enums/question_type.dart';
import '../../enums/subject_type.dart';
import '../../models/model_lesson.dart';
import '../../models/model_question.dart';

const seedLessons = <Lesson>[
  Lesson(
    id: 'fractions_intro',
    title: 'Frações na prática',
    summary:
        'Uma fração mostra quantas partes iguais de um todo estamos usando.',
    subject: SubjectType.mathematics,
    questions: [
      Question(
        id: 'fraction_1',
        prompt: 'Qual fração representa metade?',
        type: QuestionType.multipleChoice,
        options: ['1/2', '1/3', '2/3'],
        correctAnswer: '1/2',
        subjectId: 'mathematics',
        topicId: 'fractions',
      ),
      Question(
        id: 'fraction_2',
        prompt: 'Complete: duas partes de quatro são ___.',
        type: QuestionType.textInput,
        options: [],
        correctAnswer: '2/4',
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
    questions: [
      Question(
        id: 'genre_1',
        prompt: 'Qual texto ensina a preparar um alimento?',
        type: QuestionType.multipleChoice,
        options: ['Receita', 'Poema', 'Notícia'],
        correctAnswer: 'Receita',
        subjectId: 'portuguese',
        topicId: 'genres',
      ),
    ],
  ),
  Lesson(
    id: 'water_cycle',
    title: 'O ciclo da água',
    summary: 'A água circula pela natureza em transformações contínuas.',
    subject: SubjectType.science,
    questions: [
      Question(
        id: 'water_1',
        prompt: 'Como se chama a passagem da água líquida para vapor?',
        type: QuestionType.multipleChoice,
        options: ['Evaporação', 'Precipitação', 'Solidificação'],
        correctAnswer: 'Evaporação',
        subjectId: 'science',
        topicId: 'water',
      ),
    ],
  ),
];
