import 'package:eureka/enums/question_type.dart';
import 'package:eureka/enums/subject_type.dart';
import 'package:eureka/models/model_lesson.dart';
import 'package:eureka/models/model_question.dart';

List<Lesson> simulationLessons({int questionsPerLesson = 4}) {
  const subjects = [
    SubjectType.mathematics,
    SubjectType.portuguese,
    SubjectType.science,
  ];
  return subjects.indexed.map((entry) {
    final index = entry.$1;
    final subject = entry.$2;
    return Lesson(
      id: 'lesson_$index',
      title: 'Conteúdo ${index + 1}',
      summary: 'Resumo',
      subject: subject,
      questions: List.generate(
        questionsPerLesson,
        (questionIndex) => Question(
          id: 'simulation_${index}_$questionIndex',
          prompt: 'Pergunta ${questionIndex + 1}',
          type: QuestionType.multipleChoice,
          options: const ['A', 'B', 'C', 'D'],
          correctAnswer: 'A',
          subjectId: subject.name,
          topicId: 'topic_$index',
          explanation: 'A alternativa A responde corretamente à pergunta.',
          usage: QuestionUsage.simulatorExplore,
        ),
      ),
    );
  }).toList();
}
