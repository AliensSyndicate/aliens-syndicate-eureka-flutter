import 'dart:convert';

import '../enums/question_type.dart';
import '../models/model_question.dart';

class AnswerService {
  static const essayMinLength = 20;

  bool isCorrect(Question question, String answer) {
    if (question.type == QuestionType.essay) {
      return answer.trim().length >= essayMinLength;
    }
    if (question.type == QuestionType.textInput) {
      final submitted = answer.trim();
      final expected = question.correctAnswer.trim();
      return _isSingleWord(submitted) &&
          _isSingleWord(expected) &&
          submitted == expected;
    }
    if (question.type == QuestionType.matching) {
      return _matchingIsCorrect(question, answer);
    }
    return answer.trim().toLowerCase() ==
        question.correctAnswer.trim().toLowerCase();
  }

  bool _isSingleWord(String value) =>
      value.isNotEmpty && !RegExp(r'\s').hasMatch(value);

  bool _matchingIsCorrect(Question question, String answer) {
    try {
      final decoded = jsonDecode(answer);
      if (decoded is! Map || decoded.length != question.pairs?.length) {
        return false;
      }
      return question.pairs!.every((pair) => decoded[pair.left] == pair.right);
    } on FormatException {
      return false;
    }
  }
}
