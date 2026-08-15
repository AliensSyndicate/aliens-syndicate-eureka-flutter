import '../../enums/subject_type.dart';
import '../../models/content/model_activity_reference.dart';
import '../../models/content/model_content_manifest.dart';
import '../../models/model_lesson.dart';
import 'seed_content.dart';

ContentManifest buildSeedContentManifest() {
  SubjectContentManifest subject(
    String id,
    String title,
    SubjectType type,
    int order,
  ) {
    final lessons = seedLessons
        .where((lesson) => lesson.subject == type)
        .map(
          (lesson) => Lesson(
            id: lesson.id,
            title: lesson.title,
            summary: lesson.summary,
            subject: type,
            schoolYear: lesson.schoolYear,
            topicId: lesson.topicId,
            skillId: lesson.skillId,
            prerequisiteLessonIds: lesson.prerequisiteLessonIds,
            activities: [ActivityReference(id: '${lesson.id}_v1', version: 1)],
            questions: const [],
          ),
        )
        .toList();
    return SubjectContentManifest(
      id: id,
      title: title,
      type: type,
      order: order,
      schoolYears: [
        SubjectSchoolYearManifest(
          id: '${id}_year_5',
          year: 5,
          title: '5º ano',
          order: 0,
          lessons: lessons,
        ),
      ],
    );
  }

  return ContentManifest(
    schemaVersion: 1,
    contentVersion: 3,
    locale: 'pt-BR',
    updatedAt: DateTime.utc(2026, 8, 14),
    subjects: [
      subject('portuguese', 'Português', SubjectType.portuguese, 0),
      subject('english', 'Inglês', SubjectType.english, 1),
      subject('spanish', 'Espanhol', SubjectType.spanish, 2),
      subject('mathematics', 'Matemática', SubjectType.mathematics, 3),
      subject('science', 'Ciências', SubjectType.science, 4),
      subject('biology', 'Biologia', SubjectType.biology, 5),
      subject('physics', 'Física', SubjectType.physics, 6),
      subject('chemistry', 'Química', SubjectType.chemistry, 7),
      subject('history', 'História', SubjectType.history, 8),
      subject('geography', 'Geografia', SubjectType.geography, 9),
      subject('philosophy', 'Filosofia', SubjectType.philosophy, 10),
      subject('sociology', 'Sociologia', SubjectType.sociology, 11),
    ],
  );
}
