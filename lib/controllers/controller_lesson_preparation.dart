import '../models/model_lesson.dart';

class LessonPreparationController {
  LessonPreparationController({
    required Future<Lesson> Function(Lesson lesson) loadActivity,
  }) : _loadActivity = loadActivity;

  final Future<Lesson> Function(Lesson lesson) _loadActivity;

  Future<Lesson?> prepare(Lesson lesson) async {
    final loaded = await _loadActivity(lesson);
    return loaded.questions.isEmpty ? null : loaded;
  }
}
