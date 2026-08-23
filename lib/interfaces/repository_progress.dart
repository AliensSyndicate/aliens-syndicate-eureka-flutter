import '../models/model_lesson_session.dart';
import '../models/model_progress.dart';
import '../models/model_activity_result.dart';

abstract interface class ProgressRepository {
  UserProgress loadProgress();
  Future<void> saveProgress(UserProgress progress);
  LessonSession loadLessonSession(String lessonId);
  Future<void> saveLessonSession(String lessonId, LessonSession session);
  Map<String, int> loadDifficultyScores();
  Future<void> saveDifficultyScores(Map<String, int> scores);
  Future<void> saveActivityResult(ActivityResultSnapshot result);
  ActivityResultSnapshot? loadLatestActivityResult(String lessonId);
}
