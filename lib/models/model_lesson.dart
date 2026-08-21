import '../enums/subject_type.dart';
import 'model_question.dart';
import 'content/model_activity_reference.dart';
import 'content/model_content_page.dart';

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
    this.unit = '',
    this.topic = '',
    this.shortDescription = '',
    this.bnccCodes = const [],
    this.skills = const [],
    this.learningObjectives = const [],
    this.estimatedMinutes = 0,
    this.contentPages = const [],
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
  final String unit, topic, shortDescription;
  final List<String> bnccCodes, skills, learningObjectives;
  final int estimatedMinutes;
  final List<ContentPage> contentPages;

  List<Question> get practiceQuestions => List.unmodifiable(
    questions.where((question) => question.usage == QuestionUsage.practice),
  );
  List<Question> get extraQuestions => List.unmodifiable(
    questions.where(
      (question) => question.usage == QuestionUsage.simulatorExplore,
    ),
  );

  bool get hasActivity =>
      questions.isNotEmpty || activities.isNotEmpty || activityId != null;
}
