import '../interfaces/repository_simulation.dart';
import '../models/model_simulation.dart';
import '../services/service_simulation.dart';

class SimulationController {
  SimulationController({
    required SimulationRepository repository,
    required SimulationService service,
    SimulationSession? session,
  }) : _repository = repository,
       _service = service,
       _session = session ?? repository.loadActive();

  final SimulationRepository _repository;
  final SimulationService _service;
  SimulationSession? _session;
  SimulationSession get session => _session!;
  bool get hasSession => _session != null;
  SimulationQuestion get current => session.questions[session.currentIndex];
  String get currentAnswer => session.answers[current.question.id] ?? '';
  bool get isLast => session.currentIndex == session.questions.length - 1;
  int get unanswered => session.questions
      .where((item) => !session.answers.containsKey(item.question.id))
      .length;

  Future<void> start(
    List<SimulationQuestion> questions,
    Duration duration,
  ) async {
    final now = DateTime.now();
    _session = SimulationSession(
      id: now.microsecondsSinceEpoch.toString(),
      startedAt: now,
      endTime: now.add(duration),
      questions: questions,
    );
    await _repository.saveActive(session);
  }

  Future<void> answer(String value) async {
    final answers = {...session.answers};
    if (value.trim().isEmpty) {
      answers.remove(current.question.id);
    } else {
      answers[current.question.id] = value;
    }
    await _save(session.copyWith(answers: answers));
  }

  Future<void> goTo(int index) async => _save(
    session.copyWith(
      currentIndex: index.clamp(0, session.questions.length - 1),
    ),
  );

  Future<void> toggleReview() async {
    final marked = {...session.reviewQuestionIds};
    marked.contains(current.question.id)
        ? marked.remove(current.question.id)
        : marked.add(current.question.id);
    await _save(session.copyWith(reviewQuestionIds: marked));
  }

  SimulationResult result({DateTime? finishedAt}) =>
      _service.evaluateSession(session, finishedAt: finishedAt);

  Future<void> complete() async {
    _session = session.copyWith(status: SimulationStatus.completed);
    await _repository.clearActive();
  }

  Future<void> abandon() async {
    _session = session.copyWith(status: SimulationStatus.abandoned);
    await _repository.clearActive();
  }

  Future<void> _save(SimulationSession value) async {
    _session = value;
    await _repository.saveActive(value);
  }
}
