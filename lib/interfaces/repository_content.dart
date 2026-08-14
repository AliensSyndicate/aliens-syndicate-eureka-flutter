import '../models/model_lesson.dart';

abstract interface class ContentRepository {
  Future<List<Lesson>> findPublishedLessons({required int schoolYear});
}
