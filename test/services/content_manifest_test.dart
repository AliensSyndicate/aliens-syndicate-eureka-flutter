import 'dart:convert';
import 'dart:io';
import 'package:eureka/models/content/model_content_manifest.dart';
import 'package:eureka/enums/education_stage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('manifesto contém menu e mantém atividades fora do payload', () {
    final document =
        jsonDecode(
              File('firebase/content/content_manifest.json').readAsStringSync(),
            )
            as Map<String, dynamic>;
    final manifest = ContentManifest.fromMap(
      Map<String, dynamic>.from(document['payload'] as Map),
    );
    expect(manifest.contentVersion, 4);
    expect(manifest.subjects, hasLength(12));
    expect(manifest.subjectsForYear(5).map((subject) => subject.title), [
      'Ciências',
      'Geografia',
      'História',
      'Matemática',
      'Português',
    ]);
    expect(manifest.lessons.length, greaterThan(250));
    expect(
      manifest.lessons.every((lesson) => lesson.questions.isEmpty),
      isTrue,
    );
    expect(
      manifest.lessons.every((lesson) => lesson.activities.isEmpty),
      isTrue,
    );
    expect(
      manifest.subjects
          .expand((subject) => subject.schoolYears)
          .any((year) => year.id.endsWith('_em_1')),
      isTrue,
    );
    final spanish = manifest.subjects.singleWhere(
      (subject) => subject.id == 'spanish',
    );
    expect(
      spanish.schoolYears.every(
        (year) => year.curriculumSource == CurriculumSource.editorial,
      ),
      isTrue,
    );
    expect(manifest.lessonsForYear(1), isNotEmpty);
    expect(
      manifest.lessonsForYear(1, stage: EducationStage.highSchool),
      isNotEmpty,
    );
  });
}
