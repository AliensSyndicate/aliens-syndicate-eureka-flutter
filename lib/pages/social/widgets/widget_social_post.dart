import 'package:flutter/material.dart';
import '../../../models/social/model_social_post.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';
import 'widget_social_avatar.dart';

class SocialPostWidget extends StatelessWidget {
  const SocialPostWidget({
    required this.post,
    required this.onLike,
    required this.onLikesTap,
    super.key,
  });
  final SocialPost post;
  final VoidCallback onLike;
  final VoidCallback onLikesTap;

  String _relativeTime() {
    final difference = DateTime.now().difference(post.createdAt);
    if (difference.inDays > 0) {
      return difference.inDays == 1 ? '1 dia' : '${difference.inDays} dias';
    }
    return '${difference.inHours.clamp(1, 23)} h';
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: UiSpacing.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SocialAvatar(user: post.user),
            const SizedBox(width: UiSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.user.displayName, style: UiText.h6),
                  Text(_relativeTime(), style: UiText.label),
                ],
              ),
            ),
            if (post.layout != SocialPostLayout.compact)
              ExcludeSemantics(
                child: Container(
                  width: UiSize.avatarMd,
                  height: UiSize.avatarMd,
                  decoration: BoxDecoration(
                    color: UiColor.surfaceElevated,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: _eventIcon(),
                ),
              ),
          ],
        ),
        const SizedBox(height: UiSpacing.md),
        Text(
          post.title,
          style: post.layout == SocialPostLayout.featured
              ? UiText.h5
              : UiText.p,
        ),
        if (post.subtitle != null) ...[
          const SizedBox(height: UiSpacing.xs),
          Text(post.subtitle!, style: UiText.label),
        ],
        const SizedBox(height: UiSpacing.sm),
        Semantics(
          button: true,
          toggled: post.likedByCurrentUser,
          label:
              '${post.likedByCurrentUser ? 'Descurtir' : 'Curtir'} publicação de ${post.user.displayName}',
          value: '${post.likesCount} curtidas',
          child: InkWell(
            onTap: onLike,
            borderRadius: BorderRadius.circular(UiSize.touchTarget / 2),
            child: SizedBox(
              height: UiSize.touchTarget,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UiIcon.heart(
                    filled: post.likedByCurrentUser,
                    color: post.likedByCurrentUser
                        ? UiColor.error
                        : UiColor.textSecondary,
                  ),
                  const SizedBox(width: UiSpacing.xs),
                  Text('${post.likesCount}', style: UiText.label),
                ],
              ),
            ),
          ),
        ),
        if (post.likesCount > 0) _LikePreview(post: post, onTap: onLikesTap),
      ],
    ),
  );

  Widget _eventIcon() => switch (post.type.name) {
    'studyStreak' => UiIcon.flash(color: UiColor.warning),
    'badgeUnlocked' => UiIcon.star(color: UiColor.xp),
    _ => UiIcon.trophy(color: UiColor.accent),
  };
}

class _LikePreview extends StatelessWidget {
  const _LikePreview({required this.post, required this.onTap});
  final SocialPost post;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final shown = post.recentLikes.take(3).toList();
    final names = shown.map((user) => user.displayName).join(', ');
    final remaining = (post.likesCount - shown.length).clamp(
      0,
      post.likesCount,
    );
    final text = remaining > 0
        ? 'Curtido por $names e mais $remaining'
        : 'Curtido por $names';
    return Semantics(
      button: true,
      label: 'Ver pessoas que curtiram',
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: UiSize.touchTarget),
          child: Row(
            children: [
              SizedBox(
                width: shown.isEmpty
                    ? 0
                    : UiSize.avatarSm + (shown.length - 1) * 20,
                height: UiSize.avatarSm,
                child: Stack(
                  children: [
                    for (var index = 0; index < shown.length; index++)
                      Positioned(
                        left: index * 20,
                        child: SocialAvatar(
                          user: shown[index],
                          size: UiSize.avatarSm,
                        ),
                      ),
                  ],
                ),
              ),
              if (shown.isNotEmpty) const SizedBox(width: UiSpacing.sm),
              Expanded(child: Text(text, style: UiText.label)),
            ],
          ),
        ),
      ),
    );
  }
}
