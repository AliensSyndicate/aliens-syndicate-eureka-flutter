class SimulationResult {
  const SimulationResult({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.reviewTopics,
    this.strongTopics = const [],
  });
  final int correctAnswers, totalQuestions;
  final List<String> reviewTopics;
  final List<String> strongTopics;
  double get score => totalQuestions == 0 ? 0 : correctAnswers / totalQuestions;
}
