import 'package:flutter/material.dart';
import '../../models/social/model_user_preview.dart';
import '../../repositories/repository_mock_social.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_icon.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';
import '../../l10n/app_strings.dart';
import 'widgets/widget_social_avatar.dart';

class PageFriends extends StatefulWidget {
  const PageFriends({super.key});
  @override
  State<PageFriends> createState() => _PageFriendsState();
}

class _PageFriendsState extends State<PageFriends> {
  final repository = MockSocialRepository();
  List<UserPreview> users = const [];
  @override
  void initState() {
    super.initState();
    repository.loadFriends().then((value) {
      if (mounted) setState(() => users = value);
    });
  }

  Future<void> _search(String query) async {
    final result = query.trim().isEmpty
        ? await repository.loadFriends()
        : await repository.searchUsers(query);
    if (mounted) setState(() => users = result);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(AppStrings.socialFriends)),
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(UiSpacing.pageHorizontal),
            child: TextField(
              onChanged: _search,
              style: UiText.p,
              decoration: InputDecoration(
                hintText: AppStrings.friendsSearchHint,
                prefixIcon: UiIcon.search(color: UiColor.textSecondary),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: UiSpacing.pageHorizontal,
              ),
              itemCount: users.length,
              separatorBuilder: (_, _) => const Divider(color: UiColor.divider),
              itemBuilder: (_, index) {
                final user = users[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SocialAvatar(user: user),
                  title: Text(user.displayName, style: UiText.h6),
                  subtitle: Text(
                    AppStrings.friendSummary(user.schoolYear, user.xp),
                    style: UiText.label,
                  ),
                  trailing: IconButton(
                    tooltip: AppStrings.addFriend(user.displayName),
                    onPressed: () {},
                    icon: UiIcon.group(color: UiColor.accent),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
