class LessonSession {
  const LessonSession({
    this.currentPage = 0,
    this.answers = const {},
    this.results = const {},
  });

  final int currentPage;
  final Map<String, String> answers;
  final Map<String, bool> results;

  Map<String, dynamic> toMap() => {
    'current_page': currentPage,
    'answers': answers,
    'results': results,
  };

  factory LessonSession.fromMap(Map<dynamic, dynamic> value) => LessonSession(
    currentPage: value['current_page'] as int? ?? 0,
    answers: Map<String, String>.from(value['answers'] as Map? ?? const {}),
    results: Map<String, bool>.from(value['results'] as Map? ?? const {}),
  );
}
