import 'content/model_content_manifest.dart';
import 'model_lesson.dart';

class LearningRecommendation {
  const LearningRecommendation({required this.subject, required this.lesson});
  final SubjectContentManifest subject;
  final Lesson lesson;
}
