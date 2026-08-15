import 'dart:async';

import 'package:flutter/foundation.dart';

class LessonTimerService extends ValueNotifier<Duration> {
  LessonTimerService({
    this.duration = initialDuration,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       super(duration);

  static const initialDuration = Duration(minutes: 20);
  static const _tickInterval = Duration(seconds: 1);

  final Duration duration;
  final DateTime Function() _now;
  Timer? _timer;
  DateTime? _deadline;

  bool get isExpired => value == Duration.zero;

  void start() {
    if (_timer != null) return;
    _deadline = _now().add(duration);
    value = duration;
    _timer = Timer.periodic(_tickInterval, (_) => refresh());
  }

  void refresh() {
    final deadline = _deadline;
    if (deadline == null) return;
    final milliseconds = deadline.difference(_now()).inMilliseconds;
    if (milliseconds <= 0) {
      value = Duration.zero;
      _timer?.cancel();
      _timer = null;
      return;
    }
    value = Duration(seconds: (milliseconds / 1000).ceil());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
