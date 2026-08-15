import '../models/content/model_content_manifest.dart';
import '../services/service_content.dart';

class HomeController {
  HomeController(this._contentService);
  final ContentService _contentService;
  Future<List<SubjectContentManifest>> loadSubjects(int schoolYear) =>
      _contentService.loadSubjectsForYear(schoolYear);
}
