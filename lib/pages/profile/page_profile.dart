import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_icon.dart';
import '../../ui/ui_size.dart';
import '../../ui/ui_spacing.dart';

class PageProfile extends StatelessWidget {
  const PageProfile({super.key});
  @override
  Widget build(BuildContext context) {
    final user = ServiceRegistry.user.loadCurrentUser();
    final progress = ServiceRegistry.progress.load();
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: UiSpacing.pageHorizontal,
        vertical: UiSpacing.pageVertical,
      ),
      children: [
        Center(
          child: CircleAvatar(
            radius: UiSize.avatar / 2,
            backgroundColor: UiColor.primary.withValues(alpha: .15),
            child: UiIcon.user(size: UiSize.avatarMd, color: UiColor.primary),
          ),
        ),
        const SizedBox(height: UiSpacing.md),
        Text(
          user.displayName,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          '${AppStrings.schoolYear(user.schoolYear)} • ${AppStrings.temporaryAccount}',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: UiSpacing.xl),
        ListTile(
          leading: UiIcon.flash(),
          title: Text('${progress.xp} XP'),
          subtitle: Text(AppStrings.level(progress.level)),
        ),
        ListTile(
          leading: UiIcon.correct(),
          title: Text(
            AppStrings.completedLessons(progress.completedLessonIds.length),
          ),
        ),
      ],
    );
  }
}
