import '../enums/social_event_type.dart';

class SocialEvent {
  const SocialEvent({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.userId,
    this.metadata = const {},
  });
  final String id;
  final String userId;
  final SocialEventType type;
  final DateTime createdAt;
  final Map<String, Object> metadata;
}
