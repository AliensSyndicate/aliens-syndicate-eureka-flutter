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
    expect(document['enabled'], isTrue);
    expect(manifest.contentVersion, 5);
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
      manifest.lessons.every((lesson) => lesson.activities.isEmpty),
      isTrue,
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
    final spanish = manifest.subjects.singleWhere(
      (subject) => subject.id == 'spanish',
    );
    expect(
      spanish.schoolYears.every(
        (year) => year.curriculumSource == CurriculumSource.editorial,
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
    final rawSubjects =
        (document['payload'] as Map<String, dynamic>)['subjects']
            as List<dynamic>;
    expect(
      rawSubjects.expand(
        (subject) =>
            (subject as Map<String, dynamic>)['schoolYears'] as List<dynamic>,
      ),
      everyElement(contains('enabled')),
    );
  });

  test('documentos de atividade declaram disponibilidade no app', () {
    final files = Directory('firebase/content')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('_v1.json'));

    expect(files, isNotEmpty);
    for (final file in files) {
      final document =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      expect(document['enabled'], isA<bool>(), reason: file.path);
    }
  });
}
