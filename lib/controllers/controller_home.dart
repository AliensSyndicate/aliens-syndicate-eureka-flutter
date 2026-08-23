import '../models/content/model_content_manifest.dart';
import '../models/model_lesson.dart';
import '../services/service_content.dart';
import '../services/service_registry.dart';

class ContinueLearningData {
  const ContinueLearningData({
    required this.subject,
    required this.lesson,
    required this.progress,
  });
  final SubjectContentManifest subject;
  final Lesson lesson;
  final int progress;
}

class HomeController {
  HomeController(this._contentService);
  final ContentService _contentService;

  Future<List<SubjectContentManifest>> loadSubjects(int schoolYear) =>
      _contentService.loadSubjectsForYear(schoolYear);

  Future<ContinueLearningData?> loadContinueLearning(int schoolYear) async {
    final progress = ServiceRegistry.progress.load();
    final subjects = await _contentService.loadSubjectsForYear(schoolYear);
    if (subjects.isEmpty) return null;

    final lastLessonId = progress.lastLessonId;
    if (lastLessonId != null) {
      for (final subject in subjects) {
        final lessons = subject.availableLessonsForYear(schoolYear);
        for (final lesson in lessons) {
          if (lesson.id == lastLessonId) {
            final percentage = ServiceRegistry.progress.completionPercentage(
              lessons,
            );
            return ContinueLearningData(
              subject: subject,
              lesson: lesson,
              progress: percentage,
            );
          }
        }
      }
    }

    for (final subject in subjects) {
      final lessons = subject.availableLessonsForYear(schoolYear);
      if (lessons.isNotEmpty) {
        final percentage = ServiceRegistry.progress.completionPercentage(
          lessons,
        );
        return ContinueLearningData(
          subject: subject,
          lesson: lessons.first,
          progress: percentage,
        );
      }
    }
    return null;
  }

  Future<ContinueLearningData?> loadRecommendation(int schoolYear) async {
    final subjects = await _contentService.loadSubjectsForYear(schoolYear);
    if (subjects.length > 1) {
      final subject = subjects[1];
      final lessons = subject.availableLessonsForYear(schoolYear);
      if (lessons.isNotEmpty) {
        return ContinueLearningData(
          subject: subject,
          lesson: lessons.first,
          progress: 0,
        );
      }
    } else if (subjects.isNotEmpty) {
      final subject = subjects.first;
      final lessons = subject.availableLessonsForYear(schoolYear);
      if (lessons.length > 1) {
        return ContinueLearningData(
          subject: subject,
          lesson: lessons[1],
          progress: 0,
        );
      }
    }
    return null;
  }
}
