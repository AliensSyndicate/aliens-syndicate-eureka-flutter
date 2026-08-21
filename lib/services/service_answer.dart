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
      final submitted = _normalize(question, answer);
      final accepted = <String>{
        question.correctAnswer,
        ...question.acceptedAnswers,
      };
      return accepted.any(
        (expected) => submitted == _normalize(question, expected),
      );
    }
    if (question.type == QuestionType.matching) {
      return _matchingIsCorrect(question, answer);
    }
    final submitted = answer.trim().toLowerCase();
    return <String>{
      question.correctAnswer,
      ...question.acceptedAnswers,
    }.any((expected) => submitted == expected.trim().toLowerCase());
  }

  String _normalize(Question question, String value) {
    var normalized = value.trim();
    if (!question.caseSensitive) normalized = normalized.toLowerCase();
    if (question.ignoreAccents) {
      normalized = normalized
          .replaceAll(RegExp('[áàâãä]'), 'a')
          .replaceAll(RegExp('[éèêë]'), 'e')
          .replaceAll(RegExp('[íìîï]'), 'i')
          .replaceAll(RegExp('[óòôõö]'), 'o')
          .replaceAll(RegExp('[úùûü]'), 'u')
          .replaceAll('ç', 'c');
    }
    return normalized;
  }

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
