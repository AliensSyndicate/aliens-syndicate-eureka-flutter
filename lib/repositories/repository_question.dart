import '../models/model_question.dart';

abstract interface class QuestionRepository {
  Future<List<Question>> findByTopic(String topicId);
}
