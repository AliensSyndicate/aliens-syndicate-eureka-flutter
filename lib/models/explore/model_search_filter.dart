import '../../enums/subject_type.dart';

/// Filtros opcionais para refinar resultados de busca no Explorar.
class SearchFilter {
  const SearchFilter({this.subject, this.schoolYear});

  final SubjectType? subject;
  final int? schoolYear;

  bool get isActive => subject != null || schoolYear != null;

  SearchFilter copyWith({SubjectType? subject, int? schoolYear}) =>
      SearchFilter(
        subject: subject ?? this.subject,
        schoolYear: schoolYear ?? this.schoolYear,
      );

  SearchFilter withoutSubject() => SearchFilter(schoolYear: schoolYear);
  SearchFilter withoutYear() => SearchFilter(subject: subject);

  @override
  bool operator ==(Object other) =>
      other is SearchFilter &&
      other.subject == subject &&
      other.schoolYear == schoolYear;

  @override
  int get hashCode => Object.hash(subject, schoolYear);
}
