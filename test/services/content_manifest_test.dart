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
      final payload = document['payload'] as Map<String, dynamic>;
      final questions = payload['questions'] as List<dynamic>;
      expect(payload['activityVersion'], 3, reason: file.path);
      expect(questions, hasLength(10), reason: file.path);
      expect(
        questions.every(
          (question) => (question as Map<String, dynamic>)['enabled'] == true,
        ),
        isTrue,
        reason: file.path,
      );
      expect(
        questions.every(
          (question) =>
              ((question as Map<String, dynamic>)['explanation'] as String?)
                  ?.trim()
                  .isNotEmpty ==
              true,
        ),
        isTrue,
        reason: '${file.path}: toda questão precisa ensinar após o erro',
      );
      expect(
        questions
            .map(
              (question) => (question as Map<String, dynamic>)['id'] as String,
            )
            .toSet(),
        hasLength(10),
        reason: file.path,
      );
    }
  });
}
