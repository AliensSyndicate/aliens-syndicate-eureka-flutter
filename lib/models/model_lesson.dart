import '../enums/subject_type.dart';
import 'model_question.dart';
import 'content/model_activity_reference.dart';

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
    this.activityId,
    this.activityVersion = 1,
    this.activityChecksum,
    this.activities = const [],
  });
  final String id, title, summary;
  final SubjectType subject;
  final List<Question> questions;
  final int schoolYear;
  final String? topicId;
  final String? skillId;
  final List<String> prerequisiteLessonIds;
  final String? activityId;
  final int activityVersion;
  final String? activityChecksum;
  final List<ActivityReference> activities;

  bool get hasActivity =>
      questions.isNotEmpty || activities.isNotEmpty || activityId != null;
}
