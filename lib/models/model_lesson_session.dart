class LessonSession {
  const LessonSession({
    this.currentPage = 0,
    this.answers = const {},
    this.results = const {},
    this.questionIds = const [],
    this.rewardedQuestionIds = const [],
    this.activityVersion = 1,
    this.completed = false,
  });

  final int currentPage;
  final Map<String, String> answers;
  final Map<String, bool> results;
  final List<String> questionIds;
  final List<String> rewardedQuestionIds;
  final int activityVersion;
  final bool completed;

  Map<String, dynamic> toMap() => {
    'current_page': currentPage,
    'answers': answers,
    'results': results,
    'question_ids': questionIds,
    'rewarded_question_ids': rewardedQuestionIds,
    'activity_version': activityVersion,
    'completed': completed,
  };

  factory LessonSession.fromMap(Map<dynamic, dynamic> value) => LessonSession(
    currentPage: value['current_page'] as int? ?? 0,
    answers: Map<String, String>.from(value['answers'] as Map? ?? const {}),
    results: Map<String, bool>.from(value['results'] as Map? ?? const {}),
    questionIds: List<String>.from(value['question_ids'] as List? ?? const []),
    rewardedQuestionIds: List<String>.from(
      value['rewarded_question_ids'] as List? ?? const [],
    ),
    activityVersion: value['activity_version'] as int? ?? 1,
    completed: value['completed'] as bool? ?? false,
  );

  LessonSession copyWith({
    int? currentPage,
    Map<String, String>? answers,
    Map<String, bool>? results,
    List<String>? questionIds,
    List<String>? rewardedQuestionIds,
    int? activityVersion,
    bool? completed,
  }) => LessonSession(
    currentPage: currentPage ?? this.currentPage,
    answers: answers ?? this.answers,
    results: results ?? this.results,
    questionIds: questionIds ?? this.questionIds,
    rewardedQuestionIds: rewardedQuestionIds ?? this.rewardedQuestionIds,
    activityVersion: activityVersion ?? this.activityVersion,
    completed: completed ?? this.completed,
  );
}
