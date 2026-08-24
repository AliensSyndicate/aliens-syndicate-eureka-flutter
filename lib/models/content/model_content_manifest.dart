import '../../enums/subject_type.dart';
import '../../enums/education_stage.dart';
import '../model_lesson.dart';
import 'model_activity_reference.dart';

class ContentManifest {
  const ContentManifest({
    required this.schemaVersion,
    required this.contentVersion,
    required this.locale,
    required this.updatedAt,
    required this.subjects,
  });
  final int schemaVersion;
  final int contentVersion;
  final String locale;
  final DateTime updatedAt;
  final List<SubjectContentManifest> subjects;

  List<Lesson> get lessons => subjects
      .expand((subject) => subject.schoolYears)
      .where((schoolYear) => schoolYear.enabled)
      .expand((item) => item.lessons)
      .toList();
  List<SubjectContentManifest> get sortedSubjects =>
      [...subjects]
        ..sort((a, b) => _alphabetic(a.title).compareTo(_alphabetic(b.title)));

  List<Lesson> lessonsForYear(
    int year, {
    EducationStage stage = EducationStage.elementarySchool,
  }) => subjects
      .expand((subject) => subject.schoolYears)
      .where(
        (item) =>
            item.enabled && item.year == year && item.educationStage == stage,
      )
      .expand((item) => item.lessons)
      .toList();
  List<SubjectContentManifest> subjectsForYear(
    int year, {
    EducationStage stage = EducationStage.elementarySchool,
  }) => sortedSubjects
      .where(
        (subject) => subject.schoolYears.any(
          (item) =>
              item.enabled &&
              item.year == year &&
              item.educationStage == stage &&
              item.lessons.isNotEmpty,
        ),
      )
      .toList();

  factory ContentManifest.fromMap(Map<String, dynamic> map) => ContentManifest(
    schemaVersion: map['schemaVersion'] as int,
    contentVersion: map['contentVersion'] as int,
    locale: map['locale'] as String,
    updatedAt: DateTime.parse(map['updatedAt'] as String),
    subjects: _maps(map['subjects'])
        .where(
          (subject) =>
              SubjectType.values.any((type) => type.name == subject['type']),
        )
        .map(SubjectContentManifest.fromMap)
        .toList(),
  );
  Map<String, dynamic> toMap() => {
    'schemaVersion': schemaVersion,
    'contentVersion': contentVersion,
    'locale': locale,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'subjects': subjects.map((value) => value.toMap()).toList(),
  };
}

class SubjectContentManifest {
  const SubjectContentManifest({
    required this.id,
    required this.title,
    required this.type,
    required this.order,
    required this.schoolYears,
  });
  final String id, title;
  final SubjectType type;
  final int order;
  final List<SubjectSchoolYearManifest> schoolYears;
  List<Lesson> get lessons => schoolYears
      .where((item) => item.enabled)
      .expand((item) => item.lessons)
      .toList();
  List<SubjectSchoolYearManifest> schoolYearsForYear(
    int year, {
    EducationStage stage = EducationStage.elementarySchool,
  }) => schoolYears
      .where(
        (item) =>
            item.enabled && item.year == year && item.educationStage == stage,
      )
      .toList();
  List<Lesson> lessonsForYear(
    int year, {
    EducationStage stage = EducationStage.elementarySchool,
  }) => schoolYears
      .where(
        (item) =>
            item.enabled && item.year == year && item.educationStage == stage,
      )
      .expand((item) => item.lessons)
      .toList();
  List<Lesson> availableLessonsForYear(
    int year, {
    EducationStage stage = EducationStage.elementarySchool,
  }) => lessonsForYear(
    year,
    stage: stage,
  ).where((lesson) => lesson.hasActivity).toList();
  factory SubjectContentManifest.fromMap(Map<String, dynamic> map) =>
      SubjectContentManifest(
        id: map['id'] as String,
        title: map['title'] as String,
        type: SubjectType.values.byName(map['type'] as String),
        order: map['order'] as int,
        schoolYears: _maps(map['schoolYears'])
            .map(
              (year) => SubjectSchoolYearManifest.fromMap(
                year,
                SubjectType.values.byName(map['type'] as String),
              ),
            )
            .toList(),
      );
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'type': type.name,
    'order': order,
    'schoolYears': schoolYears.map((value) => value.toMap()).toList(),
  };
}

class SubjectSchoolYearManifest {
  const SubjectSchoolYearManifest({
    required this.id,
    required this.year,
    this.educationStage = EducationStage.elementarySchool,
    this.curriculumSource = CurriculumSource.bncc,
    required this.title,
    required this.order,
    required this.lessons,
    this.enabled = true,
  });
  final String id, title;
  final int year, order;
  final EducationStage educationStage;
  final CurriculumSource curriculumSource;
  final List<Lesson> lessons;
  final bool enabled;
  factory SubjectSchoolYearManifest.fromMap(
    Map<String, dynamic> map,
    SubjectType subject,
  ) => SubjectSchoolYearManifest(
    id: map['id'] as String,
    year: map['year'] as int,
    educationStage: EducationStage.values.byName(
      map['educationStage'] as String? ?? EducationStage.elementarySchool.name,
    ),
    curriculumSource: CurriculumSource.values.byName(
      map['curriculumSource'] as String? ?? CurriculumSource.bncc.name,
    ),
    title: map['title'] as String,
    order: map['order'] as int,
    enabled: map['enabled'] as bool? ?? true,
    lessons: _maps(map['lessons'])
        .map(
          (lesson) => Lesson(
            id: lesson['id'] as String,
            title: lesson['title'] as String,
            summary: lesson['summary'] as String,
            subject: subject,
            schoolYear: map['year'] as int,
            topicId: lesson['topicId'] as String?,
            skillId: lesson['skillId'] as String?,
            prerequisiteLessonIds: List<String>.from(
              lesson['prerequisiteLessonIds'] as List? ?? const [],
            ),
            activities: _maps(
              lesson['activities'],
            ).map(ActivityReference.fromMap).toList(),
            questions: const [],
          ),
        )
        .toList(),
  );
  Map<String, dynamic> toMap() => {
    'id': id,
    'year': year,
    'educationStage': educationStage.name,
    'curriculumSource': curriculumSource.name,
    'title': title,
    'order': order,
    'enabled': enabled,
    'lessons': lessons
        .map(
          (lesson) => {
            'id': lesson.id,
            'title': lesson.title,
            'summary': lesson.summary,
            'topicId': lesson.topicId,
            'skillId': lesson.skillId,
            'prerequisiteLessonIds': lesson.prerequisiteLessonIds,
            'activities': lesson.activities
                .map((activity) => activity.toMap())
                .toList(),
          },
        )
        .toList(),
  };
}

Iterable<Map<String, dynamic>> _maps(Object? value) =>
    (value as List<dynamic>? ?? const []).whereType<Map>().map(
      Map<String, dynamic>.from,
    );

String _alphabetic(String value) => value
    .toLowerCase()
    .replaceAll(RegExp('[áàâãä]'), 'a')
    .replaceAll(RegExp('[éèêë]'), 'e')
    .replaceAll(RegExp('[íìîï]'), 'i')
    .replaceAll(RegExp('[óòôõö]'), 'o')
    .replaceAll(RegExp('[úùûü]'), 'u')
    .replaceAll('ç', 'c');
