import 'dart:convert';
import 'dart:io';

import 'package:eureka/data/seed/seed_content.dart';

void main() {
  const encoder = JsonEncoder.withIndent('  ');
  for (final lesson in seedLessons) {
    final activityId = '${lesson.id}_v1';
    final lessonId = _catalogLessonIds[lesson.id]!;
    final payload = {
      'id': activityId,
      'schemaVersion': 1,
      'activityVersion': 2,
      'lessonId': lessonId,
      'subjectId': lesson.subject.name,
      'topicId': lesson.topicId,
      'schoolYear': lesson.schoolYear,
      'summary': lesson.summary,
      'questions': lesson.questions
          .map(
            (question) => {
              'id': question.id,
              'enabled': true,
              'version': question.version,
              'type': question.type.name,
              'prompt': question.prompt,
              'options': question.options,
              'correctAnswer': question.correctAnswer,
              'difficulty': question.difficulty,
              'tags': question.tags,
              'subjectId': question.subjectId,
              'topicId': question.topicId,
            },
          )
          .toList(),
    };
    final document = {
      'id': activityId,
      'published': true,
      'enabled': true,
      'payload': payload,
    };
    File(
      'firebase/content/${lesson.id}_v1.json',
    ).writeAsStringSync('${encoder.convert(document)}\n');
  }
}

const _catalogLessonIds = {
  'fractions_intro': 'mathematics_ef_5_2',
  'text_genres': 'portuguese_ef_5_6',
  'water_cycle': 'science_ef_5_2',
};
