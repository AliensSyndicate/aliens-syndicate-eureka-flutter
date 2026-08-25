import '../models/model_activity_result.dart';
import '../models/model_progress.dart';
import '../models/model_lesson_session.dart';

abstract interface class CloudProgressRepository {
  Future<void> saveProgress(UserProgress progress);
  Future<void> saveActivityResult(ActivityResultSnapshot result);
  Future<void> saveLessonRewardState(String lessonId, LessonSession session);
}
