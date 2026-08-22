import '../../enums/social_event_type.dart';
import 'model_user_preview.dart';

enum SocialPostLayout { standard, compact, featured }

class SocialPost {
  const SocialPost({
    required this.id,
    required this.user,
    required this.type,
    required this.title,
    required this.createdAt,
    required this.likesCount,
    required this.likedByCurrentUser,
    this.subtitle,
    this.recentLikes = const [],
    this.layout = SocialPostLayout.compact,
  });
  final String id;
  final UserPreview user;
  final SocialEventType type;
  final String title;
  final String? subtitle;
  final DateTime createdAt;
  final int likesCount;
  final bool likedByCurrentUser;
  final List<UserPreview> recentLikes;
  final SocialPostLayout layout;
  SocialPost copyWith({int? likesCount, bool? likedByCurrentUser}) =>
      SocialPost(
        id: id,
        user: user,
        type: type,
        title: title,
        subtitle: subtitle,
        createdAt: createdAt,
        likesCount: likesCount ?? this.likesCount,
        likedByCurrentUser: likedByCurrentUser ?? this.likedByCurrentUser,
        recentLikes: recentLikes,
        layout: layout,
      );
}

class SocialFeedPage {
  const SocialFeedPage({required this.posts, required this.hasMore});
  final List<SocialPost> posts;
  final bool hasMore;
}
