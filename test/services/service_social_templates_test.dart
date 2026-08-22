import 'package:eureka/enums/social_event_type.dart';
import 'package:eureka/models/model_social_event.dart';
import 'package:eureka/services/service_social_templates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = SocialTemplateService();
  test('gera texto infantil e positivo a partir de metadados estruturados', () {
    final event = SocialEvent(
      id: '1',
      userId: 'maria',
      type: SocialEventType.badgeUnlocked,
      createdAt: DateTime(2026),
      metadata: const {'badge': 'Ouro', 'topic': 'Frações'},
    );
    expect(service.titleFor(event), 'Conquistou Ouro em Frações!');
  });
  test('gera resultado de simulado sem conceder XP', () {
    final event = SocialEvent(
      id: '2',
      userId: 'joao',
      type: SocialEventType.simulationCompleted,
      createdAt: DateTime(2026),
      metadata: const {'score': 87},
    );
    expect(service.titleFor(event), 'Terminou o simulado com 87%!');
    expect(service.titleFor(event), isNot(contains('XP')));
  });
}
