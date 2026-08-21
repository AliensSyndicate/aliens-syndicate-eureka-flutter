import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/data/seed/seed_content_manifest.dart';
import 'package:eureka/enums/education_stage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('manifesto seed contém menu e mantém atividades fora do payload', () {
    final manifest = buildSeedContentManifest();
    expect(manifest.contentVersion, 8);
    expect(manifest.subjects, hasLength(12));
    expect(manifest.subjectsForYear(5).map((subject) => subject.title), [
      'Ciências',
      'Geografia',
      'História',
      'Matemática',
      'Português',
    ]);
    expect(manifest.lessons, hasLength(34));
    expect(
      manifest.lessons.every((lesson) => lesson.questions.isEmpty),
      isTrue,
    );
    expect(
      manifest.lessons.where((lesson) => lesson.activities.isNotEmpty),
      hasLength(3),
    );
    expect(
      manifest.subjects
          .expand((subject) => subject.schoolYears)
          .where((year) => year.enabled)
          .every(
            (year) =>
                year.year == 5 &&
                year.educationStage == EducationStage.elementarySchool,
          ),
      isTrue,
    );
    expect(manifest.lessonsForYear(1), isEmpty);
    expect(
      manifest.lessonsForYear(1, stage: EducationStage.highSchool),
      isEmpty,
    );
    final subjects = manifest.toMap()['subjects'] as List<dynamic>;
    expect(
      subjects.expand(
        (subject) =>
            (subject as Map<String, dynamic>)['schoolYears'] as List<dynamic>,
      ),
      everyElement(contains('enabled')),
    );
  });

  test('fallback seed mantém questões válidas e explicações pedagógicas', () {
    expect(seedLessons, isNotEmpty);
    for (final lesson in seedLessons) {
      expect(lesson.questions, isNotEmpty, reason: lesson.id);
      expect(
        lesson.questions.every(
          (question) => question.incorrectFeedback.trim().isNotEmpty,
        ),
        isTrue,
        reason: '${lesson.id}: toda questão precisa ensinar após o erro',
      );
      expect(
        lesson.questions.map((question) => question.id).toSet(),
        hasLength(lesson.questions.length),
        reason: lesson.id,
      );
    }
  });
}
