import '../interfaces/repository_search.dart';
import '../models/content/model_content_manifest.dart';
import '../models/explore/model_search_filter.dart';
import '../models/explore/model_search_result.dart';
import '../services/service_content.dart';

/// Implementação local do [SearchRepository] usando o [ContentService].
///
/// Delega toda normalização e filtragem ao service, mantendo a UI
/// completamente desacoplada do motor de busca.
class LocalSearchRepository implements SearchRepository {
  const LocalSearchRepository(this._content);
  final ContentService _content;

  @override
  Future<List<SearchResult>> search(
    String query, {
    SearchFilter? filter,
  }) async {
    final lessons = _content.searchAllLessons(
      query,
      subjectId: filter?.subject?.name,
      schoolYear: filter?.schoolYear,
    );

    return lessons.map((lesson) {
      final subjectName = _content.subjectNameForLesson(lesson);
      return SearchResult.fromLesson(lesson, subjectName);
    }).toList();
  }

  @override
  Future<List<SubjectContentManifest>> getSubjects() async =>
      _content.getAllSubjects();
}
