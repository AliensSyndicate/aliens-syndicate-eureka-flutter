import '../enums/subject_type.dart';
import 'model_question.dart';

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.summary,
    required this.subject,
    required this.questions,
    this.schoolYear = 5,
    this.topicId,
    this.skillId,
    this.prerequisiteLessonIds = const [],
  });
  final String id, title, summary;
  final SubjectType subject;
  final List<Question> questions;
  final int schoolYear;
  final String? topicId;
  final String? skillId;
  final List<String> prerequisiteLessonIds;
}
