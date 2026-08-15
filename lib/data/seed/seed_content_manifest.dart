import '../../enums/education_stage.dart';
import '../../enums/subject_type.dart';
import '../../config/config_product.dart';
import '../../models/content/model_content_manifest.dart';
import '../../models/model_lesson.dart';
import 'seed_curriculum.dart';

ContentManifest buildSeedContentManifest() => ContentManifest(
  schemaVersion: 1,
  contentVersion: 5,
  locale: 'pt-BR',
  updatedAt: DateTime.utc(2026, 8, 14),
  subjects: _subjects.indexed.map((entry) {
    final (order, definition) = entry;
    final grades = seedCurriculum[definition.type] ?? const [];
    return SubjectContentManifest(
      id: definition.type.name,
      title: definition.title,
      type: definition.type,
      order: order,
      schoolYears: grades.indexed.map((gradeEntry) {
        final (gradeOrder, grade) = gradeEntry;
        final stageId = grade.stage == EducationStage.elementarySchool
            ? 'ef'
            : 'em';
        return SubjectSchoolYearManifest(
          id: '${definition.type.name}_${stageId}_${grade.year}',
          year: grade.year,
          educationStage: grade.stage,
          curriculumSource:
              grade.stage == EducationStage.highSchool ||
                  definition.type == SubjectType.spanish
              ? CurriculumSource.editorial
              : CurriculumSource.bncc,
          title: grade.stage.yearLabel(grade.year),
          order: gradeOrder,
          enabled:
              grade.stage == EducationStage.elementarySchool &&
              grade.year == ProductConfig.v1SchoolYear,
          lessons: grade.items.indexed.map((itemEntry) {
            final (itemOrder, title) = itemEntry;
            final id =
                '${definition.type.name}_${stageId}_${grade.year}_${itemOrder + 1}';
            return Lesson(
              id: id,
              title: title,
              summary: '',
              subject: definition.type,
              schoolYear: grade.year,
              topicId: id,
              prerequisiteLessonIds: itemOrder == 0
                  ? const []
                  : ['${definition.type.name}_${stageId}_${grade.year}_$itemOrder'],
              activities: const [],
              questions: const [],
            );
          }).toList(),
        );
      }).toList(),
    );
  }).toList(),
);

class _SubjectDefinition {
  const _SubjectDefinition(this.type, this.title);
  final SubjectType type;
  final String title;
}

const _subjects = [
  _SubjectDefinition(SubjectType.portuguese, 'Português'),
  _SubjectDefinition(SubjectType.english, 'Inglês'),
  _SubjectDefinition(SubjectType.spanish, 'Espanhol'),
  _SubjectDefinition(SubjectType.mathematics, 'Matemática'),
  _SubjectDefinition(SubjectType.science, 'Ciências'),
  _SubjectDefinition(SubjectType.biology, 'Biologia'),
  _SubjectDefinition(SubjectType.physics, 'Física'),
  _SubjectDefinition(SubjectType.chemistry, 'Química'),
  _SubjectDefinition(SubjectType.history, 'História'),
  _SubjectDefinition(SubjectType.geography, 'Geografia'),
  _SubjectDefinition(SubjectType.philosophy, 'Filosofia'),
  _SubjectDefinition(SubjectType.sociology, 'Sociologia'),
];
