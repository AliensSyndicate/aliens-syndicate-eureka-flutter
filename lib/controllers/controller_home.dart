import '../models/model_lesson.dart';
import '../services/service_content.dart';

class HomeController {
  HomeController(this._contentService);
  final ContentService _contentService;
  Future<List<Lesson>> loadJourney() => _contentService.loadJourneyLessons();
}
