abstract interface class AnalyticsService {
  Future<void> track(
    String event, [
    Map<String, Object?> parameters = const {},
  ]);
}

class NoopAnalyticsService implements AnalyticsService {
  @override
  Future<void> track(
    String event, [
    Map<String, Object?> parameters = const {},
  ]) async {}
}
