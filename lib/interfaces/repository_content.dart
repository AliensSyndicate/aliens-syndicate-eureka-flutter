import '../models/model_lesson.dart';
import '../models/content/model_content_manifest.dart';

abstract interface class ContentRepository {
  Future<List<Lesson>> findPublishedLessons({required int schoolYear});
  Future<ContentManifest?> fetchManifest();
  Future<Map<String, dynamic>?> fetchActivity(String activityId);
}
