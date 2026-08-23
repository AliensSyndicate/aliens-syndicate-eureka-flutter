import 'dart:async';

import '../interfaces/repository_simulation.dart';
import '../interfaces/service_analytics.dart';
import '../models/model_simulation.dart';
import '../services/service_simulation.dart';

class SimulationController {
  SimulationController({
    required SimulationRepository repository,
    required SimulationService service,
    SimulationSession? session,
    DateTime Function()? now,
    AnalyticsService? analytics,
  }) : _repository = repository,
       _service = service,
       _now = now ?? DateTime.now,
       _analytics = analytics ?? NoopAnalyticsService(),
       _session = session ?? repository.loadActive();

  final SimulationRepository _repository;
  final SimulationService _service;
  final DateTime Function() _now;
  final AnalyticsService _analytics;
  SimulationSession? _session;
  Future<SimulationResult>? _completion;
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
    final now = _now();
    _session = SimulationSession(
      id: now.microsecondsSinceEpoch.toString(),
      startedAt: now,
      endTime: now.add(duration),
      questions: questions,
    );
    await _repository.saveActive(session);
    unawaited(
      _analytics.track('simulation_started', {
        'session_id': session.id,
        'question_count': questions.length,
        'duration_seconds': duration.inSeconds,
      }),
    );
  }

  Future<void> answer(String value) async {
    final answers = {...session.answers};
    if (value.trim().isEmpty) {
      answers.remove(current.question.id);
    } else {
      answers[current.question.id] = value;
    }
    await _save(session.copyWith(answers: answers));
    unawaited(
      _analytics.track('simulation_answer_changed', {
        'session_id': session.id,
        'question_id': current.question.id,
        'answered': value.trim().isNotEmpty,
      }),
    );
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
    unawaited(
      _analytics.track('simulation_review_toggled', {
        'session_id': session.id,
        'question_id': current.question.id,
        'marked': marked.contains(current.question.id),
      }),
    );
  }

  SimulationResult result({DateTime? finishedAt}) =>
      _service.evaluateSession(session, finishedAt: finishedAt ?? _now());

  Future<SimulationResult> complete({bool expired = false}) async {
    final pending = _completion;
    if (pending != null) return pending;
    final created = _complete(expired: expired);
    _completion = created;
    try {
      return await created;
    } on Object {
      _completion = null;
      rethrow;
    }
  }

  Future<SimulationResult> _complete({required bool expired}) async {
    if (session.status == SimulationStatus.completed ||
        session.status == SimulationStatus.expired) {
      return _repository.loadCompleted(session.id)?.result ?? result();
    }
    final completedAt = _now();
    final completedSession = session.copyWith(
      status: expired ? SimulationStatus.expired : SimulationStatus.completed,
    );
    final completedResult = _service.evaluateSession(
      completedSession,
      finishedAt: completedAt,
    );
    await _repository.saveCompleted(
      CompletedSimulation(
        session: completedSession,
        result: completedResult,
        completedAt: completedAt,
      ),
    );
    _session = completedSession;
    await _repository.clearActive();
    unawaited(
      _analytics.track('simulation_completed', {
        'session_id': completedSession.id,
        'status': completedSession.status.name,
        'correct': completedResult.correctAnswers,
        'total': completedResult.totalQuestions,
        'unanswered': completedResult.unansweredQuestions,
      }),
    );
    return completedResult;
  }

  Future<void> abandon() async {
    _session = session.copyWith(status: SimulationStatus.abandoned);
    await _repository.clearActive();
    unawaited(
      _analytics.track('simulation_abandoned', {
        'session_id': session.id,
        'answered': session.answers.length,
        'total': session.questions.length,
      }),
    );
  }

  Future<void> _save(SimulationSession value) async {
    _session = value;
    await _repository.saveActive(value);
  }
}
