import 'dart:convert';
import 'dart:io';
import 'package:eureka/models/content/model_content_manifest.dart';
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
    final lessons = manifest.lessonsForYear(5);
    expect(manifest.contentVersion, 3);
    expect(manifest.subjects, hasLength(12));
    expect(manifest.subjectsForYear(5).map((subject) => subject.title), [
      'Biologia',
      'Ciências',
      'Espanhol',
      'Filosofia',
      'Física',
      'Geografia',
      'História',
      'Inglês',
      'Matemática',
      'Português',
      'Química',
      'Sociologia',
    ]);
    expect(lessons, hasLength(3));
    expect(lessons.every((lesson) => lesson.questions.isEmpty), isTrue);
    expect(lessons.every((lesson) => lesson.activities.isNotEmpty), isTrue);
  });
}
