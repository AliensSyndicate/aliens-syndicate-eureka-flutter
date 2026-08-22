import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/components/app_bottom_sheet.dart';
import '../../controllers/controller_social.dart';
import '../../repositories/repository_mock_social.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_icon.dart';
import '../../ui/ui_size.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';
import 'widgets/widget_social_avatar.dart';
import 'widgets/widget_social_post.dart';
import 'widgets/widget_social_skeleton.dart';

class PageSocial extends StatefulWidget {
  const PageSocial({super.key, this.controller});
  final SocialController? controller;
  @override
  State<PageSocial> createState() => _PageSocialState();
}

class _PageSocialState extends State<PageSocial> {
  late final SocialController controller;
  late final ScrollController scrollController;
  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? SocialController(MockSocialRepository());
    scrollController = ScrollController()..addListener(_onScroll);
    controller.addListener(_refresh);
    if (controller.status == SocialFeedStatus.initial) controller.loadInitial();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (scrollController.position.extentAfter < 320) controller.loadMore();
  }

  @override
  void dispose() {
    controller.removeListener(_refresh);
    scrollController.dispose();
    if (widget.controller == null) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            UiSpacing.pageHorizontal,
            UiSpacing.pageVertical,
            UiSpacing.xs,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text('Novidades', style: UiText.h3),
                ),
              ),
              _HeaderAction(
                label: 'Ranking',
                icon: UiIcon.trophy(size: UiSize.iconSm),
                onTap: () => context.push('/social/ranking'),
              ),
              _HeaderAction(
                label: 'Amigos',
                icon: UiIcon.group(size: UiSize.iconSm),
                onTap: () => context.push('/social/friends'),
              ),
            ],
          ),
        ),
        Expanded(child: _body()),
      ],
    ),
  );
  Widget _body() {
    if (controller.status == SocialFeedStatus.loading) {
      return const SocialSkeleton();
    }
    if (controller.status == SocialFeedStatus.error &&
        controller.posts.isEmpty) {
      return _MessageState(
        message: 'Não foi possível carregar as novidades.',
        action: 'Tentar novamente',
        onTap: controller.loadInitial,
      );
    }
    if (controller.status == SocialFeedStatus.empty) {
      return _MessageState(
        message: 'Quando seus amigos estudarem, as novidades aparecem aqui.',
        action: 'Encontrar amigos',
        onTap: () => context.push('/social/friends'),
      );
    }
    return RefreshIndicator(
      color: UiColor.accent,
      backgroundColor: UiColor.surface,
      onRefresh: controller.refresh,
      child: ListView.separated(
        key: const Key('social_feed'),
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: UiSpacing.pageHorizontal,
        ),
        itemCount: controller.posts.length + (controller.hasMore ? 1 : 0),
        separatorBuilder: (_, index) => index < controller.posts.length - 1
            ? const Divider(height: 1, color: UiColor.divider)
            : const SizedBox.shrink(),
        itemBuilder: (context, index) {
          if (index == controller.posts.length) {
            return const Padding(
              padding: EdgeInsets.all(UiSpacing.md),
              child: Center(
                child: SizedBox.square(
                  dimension: UiSize.iconMd,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: UiColor.accent,
                  ),
                ),
              ),
            );
          }
          final post = controller.posts[index];
          return SocialPostWidget(
            post: post,
            onLike: () => controller.toggleLike(post.id),
            onLikesTap: () async {
              final users = await controller.repository.loadLikes(post.id);
              if (!context.mounted) return;
              AppBottomSheet.show<void>(
                context,
                title: 'Curtidas',
                content: Column(
                  children: [
                    for (final user in users)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: SocialAvatar(user: user),
                        title: Text(user.displayName, style: UiText.p),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final Widget icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Abrir $label',
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UiSize.touchTarget / 2),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: UiSize.touchTarget),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: UiSpacing.xs),
          child: Row(
            children: [
              icon,
              const SizedBox(width: UiSpacing.xxs),
              Text(label, style: UiText.label),
            ],
          ),
        ),
      ),
    ),
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.message,
    required this.action,
    required this.onTap,
  });
  final String message;
  final String action;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(UiSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UiIcon.group(size: UiSize.avatarLg, color: UiColor.textSecondary),
          const SizedBox(height: UiSpacing.md),
          Text(message, style: UiText.p, textAlign: TextAlign.center),
          const SizedBox(height: UiSpacing.md),
          TextButton(onPressed: onTap, child: Text(action)),
        ],
      ),
    ),
  );
}
