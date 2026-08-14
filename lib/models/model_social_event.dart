class SocialEvent {
  const SocialEvent({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.title,
  });
  final String id;
  final String type;
  final DateTime createdAt;
  final String title;
}
