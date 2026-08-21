import '../../enums/question_type.dart';
import '../../models/content/model_content_page.dart';
import '../../models/model_matching_pair.dart';
import '../../models/model_question.dart';

class DecodedContentActivity {
  const DecodedContentActivity({
    required this.summary,
    required this.questions,
    required this.contentPages,
    required this.unit,
    required this.topic,
    required this.shortDescription,
    required this.bnccCodes,
    required this.skills,
    required this.learningObjectives,
    required this.estimatedMinutes,
  });

  final String summary, unit, topic, shortDescription;
  final List<Question> questions;
  final List<ContentPage> contentPages;
  final List<String> bnccCodes, skills, learningObjectives;
  final int estimatedMinutes;
}

/// Converte tanto o payload legado quanto o schema editorial V2 em domínio.
/// Um item inválido é descartado; um documento inválido nunca lança para a UI.
abstract final class ContentActivityCodec {
  static DecodedContentActivity? decode(Map<String, dynamic> payload) {
    try {
      final questions =
          _maps(
                payload['questions'] ??
                    [
                      ...?_list(payload['practice_exercises']),
                      ...?_list(payload['extra_exercises']),
                    ],
              )
              .where((raw) => raw['enabled'] != false)
              .map(
                (raw) => _question(
                  raw,
                  subjectId: _string(
                    payload['subjectId'] ??
                        payload['subject_id'] ??
                        payload['subject'],
                  ),
                  topicId: _string(payload['topicId'] ?? payload['topic_id']),
                ),
              )
              .whereType<Question>()
              .toList();
      final hasSeparatedExercises =
          payload.containsKey('practice_exercises') ||
          payload.containsKey('extra_exercises');
      if (hasSeparatedExercises &&
          (questions
                      .where((item) => item.usage == QuestionUsage.practice)
                      .length !=
                  5 ||
              questions
                      .where(
                        (item) => item.usage == QuestionUsage.simulatorExplore,
                      )
                      .length !=
                  3)) {
        return null;
      }
      if (questions.map((item) => item.id).toSet().length != questions.length) {
        return null;
      }
      final pages =
          _maps(
              payload['content_pages'] ?? payload['contentPages'],
            ).map(_page).whereType<ContentPage>().toList()
            ..sort((a, b) => a.page.compareTo(b.page));
      return DecodedContentActivity(
        summary: _string(payload['summary']),
        questions: questions,
        contentPages: pages,
        unit: _string(payload['unit']),
        topic: _string(payload['topic']),
        shortDescription: _string(
          payload['short_description'] ?? payload['shortDescription'],
        ),
        bnccCodes: _strings(payload['bncc_codes'] ?? payload['bnccCodes']),
        skills: _strings(payload['skills']),
        learningObjectives: _strings(
          payload['learning_objectives'] ?? payload['learningObjectives'],
        ),
        estimatedMinutes: _integer(
          payload['estimated_minutes'] ?? payload['estimatedMinutes'],
        ),
      );
    } on Object {
      return null;
    }
  }

  static Question? _question(
    Map<String, dynamic> map, {
    required String subjectId,
    required String topicId,
  }) {
    try {
      final type = _questionType(_string(map['type']));
      if (type == null) return null;
      final parameters = _map(map['parameters']);
      final answer = _map(map['correct_answer'] ?? map['correctAnswer']);
      final optionMaps = _maps(parameters['options']);
      final optionTextById = {
        for (final option in optionMaps)
          _string(option['id']): _string(option['text']),
      };
      var options = optionMaps.isNotEmpty
          ? optionTextById.values.toList()
          : _strings(map['options'] ?? parameters['items']);
      if (parameters['items'] is List) {
        final items = _maps(parameters['items']);
        if (items.isNotEmpty) {
          options = items.map((item) => _string(item['text'])).toList();
        }
      }
      final pairs = _pairs(parameters, map, type);
      var correctAnswer = _correctAnswer(
        map['correctAnswer'],
        answer,
        optionTextById,
        parameters,
      );
      final acceptedAnswers = _strings(
        parameters['accepted_answers'] ?? parameters['acceptedAnswers'],
      );
      if (type == QuestionType.sequencing && answer['ordered_ids'] is List) {
        final items = _maps(parameters['items']);
        final byId = {
          for (final item in items) _string(item['id']): _string(item['text']),
        };
        correctAnswer = _strings(
          answer['ordered_ids'],
        ).map((id) => byId[id]).whereType<String>().join(' | ');
      }
      if (type == QuestionType.trueFalse) {
        options = const ['Verdadeiro', 'Falso'];
        correctAnswer = _string(correctAnswer).toLowerCase() == 'true'
            ? 'Verdadeiro'
            : 'Falso';
      }
      if (type == QuestionType.fillBlank && options.isEmpty) {
        options = <String>{
          _string(correctAnswer),
          ...acceptedAnswers,
        }.where((value) => value.isNotEmpty).toList();
      }
      final template = _nullableString(
        map['template'] ?? parameters['sentence'] ?? parameters['template'],
      );
      return Question(
        id: _requiredString(map['id']),
        prompt: _requiredString(map['statement'] ?? map['prompt']),
        instruction: _string(map['instruction']),
        usage: _usage(map['usage']),
        type: type,
        options: options,
        correctAnswer: _requiredString(correctAnswer),
        acceptedAnswers: acceptedAnswers,
        caseSensitive:
            parameters['case_sensitive'] as bool? ??
            parameters['caseSensitive'] as bool? ??
            true,
        ignoreAccents:
            parameters['ignore_accents'] as bool? ??
            parameters['ignoreAccents'] as bool? ??
            false,
        explanation: _requiredString(
          map['correct_answer_explanation'] ?? map['explanation'],
        ),
        subjectId: _requiredString(
          map['subjectId'] ?? map['subject_id'] ?? subjectId,
        ),
        topicId: _requiredString(map['topicId'] ?? map['topic_id'] ?? topicId),
        pairs: pairs,
        template: template,
        difficulty: _difficulty(map['difficulty']),
        tags: _strings(map['tags']),
        version: _integer(map['version'], fallback: 1),
      );
    } on Object {
      return null;
    }
  }

  static List<MatchingPair>? _pairs(
    Map<String, dynamic> parameters,
    Map<String, dynamic> map,
    QuestionType type,
  ) {
    if (type != QuestionType.matching && type != QuestionType.memory) {
      return null;
    }
    final legacy = _maps(map['pairs']);
    if (legacy.isNotEmpty) {
      return legacy
          .map(
            (pair) => MatchingPair(
              left: _requiredString(pair['left']),
              right: _requiredString(pair['right']),
            ),
          )
          .toList();
    }
    final left = _maps(parameters['left_items']);
    final right = _maps(parameters['right_items']);
    final rightById = {
      for (final item in right) _string(item['id']): _string(item['text']),
    };
    final answerPairs = _maps(_map(map['correct_answer'])['pairs']);
    final leftById = {
      for (final item in left) _string(item['id']): _string(item['text']),
    };
    return answerPairs
        .map(
          (pair) => MatchingPair(
            left: _requiredString(leftById[_string(pair['left_id'])]),
            right: _requiredString(rightById[_string(pair['right_id'])]),
          ),
        )
        .toList();
  }

  static Object? _correctAnswer(
    Object? legacy,
    Map<String, dynamic> answer,
    Map<String, String> optionTextById,
    Map<String, dynamic> parameters,
  ) {
    if (legacy is String) return legacy;
    if (answer.containsKey('option_id')) {
      return optionTextById[_string(answer['option_id'])];
    }
    if (answer.containsKey('value')) return answer['value'].toString();
    if (answer['ordered_ids'] is List) {
      final items = _maps(parameters['items']);
      final byId = {
        for (final item in items) _string(item['id']): _string(item['text']),
      };
      return _strings(
        answer['ordered_ids'],
      ).map((id) => byId[id]).whereType<String>().join(' ');
    }
    if (answer['pairs'] is List) return '__matching_done__';
    return null;
  }

  static ContentPage? _page(Map<String, dynamic> map) {
    try {
      return ContentPage(
        page: _integer(map['page']),
        type: _requiredString(map['type']),
        title: _requiredString(map['title']),
        text: _requiredString(map['text']),
        visualDescription: _string(
          map['visual_description'] ?? map['visualDescription'],
        ),
        keyConcept: _string(map['key_concept'] ?? map['keyConcept']),
      );
    } on Object {
      return null;
    }
  }

  static QuestionType? _questionType(String value) {
    final normalized = value.replaceAll('_', '').toLowerCase();
    for (final type in QuestionType.values) {
      if (type.name.toLowerCase() == normalized) {
        return type;
      }
    }
    return null;
  }

  static QuestionUsage _usage(Object? value) =>
      _string(value).replaceAll('_', '').toLowerCase() == 'simulatorexplore'
      ? QuestionUsage.simulatorExplore
      : QuestionUsage.practice;
  static int _difficulty(Object? value) => switch (value) {
    'easy' => 1,
    'medium' => 2,
    'hard' => 3,
    int number => number,
    _ => 1,
  };
  static List<dynamic>? _list(Object? value) => value is List ? value : null;
  static Iterable<Map<String, dynamic>> _maps(Object? value) =>
      (value is List ? value : const []).whereType<Map>().map(
        Map<String, dynamic>.from,
      );
  static Map<String, dynamic> _map(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : const {};
  static List<String> _strings(Object? value) =>
      (value is List ? value : const [])
          .whereType<Object>()
          .map((item) => item.toString())
          .toList();
  static String _string(Object? value) => value?.toString() ?? '';
  static String? _nullableString(Object? value) {
    final result = _string(value);
    return result.isEmpty ? null : result;
  }

  static String _requiredString(Object? value) {
    final result = _string(value).trim();
    if (result.isEmpty) throw const FormatException('Campo obrigatório vazio.');
    return result;
  }

  static int _integer(Object? value, {int fallback = 0}) =>
      value is int ? value : fallback;
}
