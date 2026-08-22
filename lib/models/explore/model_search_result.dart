import '../../enums/subject_type.dart';
import '../model_lesson.dart';

/// Modelo de apresentação para resultados de busca no Explorar.
///
/// Desacopla a UI da estrutura interna de [Lesson] e permite
/// substituir o backend de busca sem alterar widgets.
class SearchResult {
  const SearchResult({
    required this.contentId,
    required this.title,
    required this.subjectType,
    required this.subjectName,
    required this.schoolYear,
    required this.lesson,
    this.description,
  });

  final String contentId;
  final String title;
  final SubjectType subjectType;
  final String subjectName;
  final int schoolYear;
  final String? description;

  /// Referência à lição original para navegação.
  final Lesson lesson;

  factory SearchResult.fromLesson(Lesson lesson, String subjectName) =>
      SearchResult(
        contentId: lesson.id,
        title: lesson.title,
        subjectType: lesson.subject,
        subjectName: subjectName,
        schoolYear: lesson.schoolYear,
        description: lesson.summary.isNotEmpty ? lesson.summary : null,
        lesson: lesson,
      );
}
