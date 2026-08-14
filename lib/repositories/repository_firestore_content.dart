import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/question_type.dart';
import '../enums/subject_type.dart';
import '../interfaces/repository_content.dart';
import '../models/model_lesson.dart';
import '../models/model_question.dart';

class FirestoreContentRepository implements ContentRepository {
  FirestoreContentRepository(this._firestore);
  final FirebaseFirestore _firestore;
  @override
  Future<List<Lesson>> findPublishedLessons({required int schoolYear}) async {
    final snapshot = await _firestore
        .collection('lessons')
        .where('published', isEqualTo: true)
        .where('schoolYear', isEqualTo: schoolYear)
        .limit(20)
        .get();
    return snapshot.docs.map((doc) => _lesson(doc.id, doc.data())).toList();
  }

  Lesson _lesson(String id, Map<String, dynamic> data) {
    final questions = (data['questions'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((raw) {
          final map = Map<String, dynamic>.from(raw);
          return Question(
            id: map['id'] as String,
            prompt: map['prompt'] as String,
            type: QuestionType.values.byName(map['type'] as String),
            options: List<String>.from(map['options'] as List? ?? []),
            correctAnswer: map['correctAnswer'] as String,
            subjectId: map['subjectId'] as String,
            topicId: map['topicId'] as String,
            difficulty: map['difficulty'] as int? ?? 1,
            tags: List<String>.from(map['tags'] as List? ?? []),
            version: map['version'] as int? ?? 1,
          );
        })
        .toList();
    return Lesson(
      id: id,
      title: data['title'] as String,
      summary: data['summary'] as String,
      subject: SubjectType.values.byName(data['subject'] as String),
      questions: questions,
    );
  }
}
