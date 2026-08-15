import 'package:eureka/services/service_lesson_timer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('inicia em vinte minutos e calcula a contagem pelo prazo final', () {
    var now = DateTime(2026, 8, 15, 12);
    final service = LessonTimerService(now: () => now)..start();
    addTearDown(service.dispose);

    expect(service.value, const Duration(minutes: 20));

    now = now.add(const Duration(seconds: 1));
    service.refresh();
    expect(service.value, const Duration(minutes: 19, seconds: 59));

    now = now.add(const Duration(minutes: 25));
    service.refresh();
    expect(service.value, Duration.zero);
    expect(service.isExpired, isTrue);
  });
}
