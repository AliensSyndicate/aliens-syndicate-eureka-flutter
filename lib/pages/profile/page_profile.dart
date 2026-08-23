import 'package:flutter/material.dart';
import '../../app/components/app_bottom_sheet.dart';
import '../../app/components/app_button.dart';
import '../../config/config_product.dart';
import '../../enums/login_context.dart';
import '../../l10n/app_strings.dart';
import '../../models/auth/model_login_request.dart';
import '../auth/login_bottom_sheet.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_icon.dart';
import '../../ui/ui_size.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';

class PageProfile extends StatefulWidget {
  const PageProfile({super.key});
  @override
  State<PageProfile> createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile> {
  @override
  Widget build(BuildContext context) {
    final user = ServiceRegistry.user.loadCurrentUser();
    final progress = ServiceRegistry.progress.load();
    final isAuthenticated = ServiceRegistry.user.isAuthenticated;
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
        Text(user.displayName, textAlign: TextAlign.center, style: UiText.h4),
        Text(
          '${AppStrings.schoolYear(user.schoolYear)} • '
          '${isAuthenticated ? AppStrings.connectedAccount : AppStrings.temporaryAccount}',
          textAlign: TextAlign.center,
          style: UiText.label,
        ),
        const SizedBox(height: UiSpacing.xl),
        ListTile(
          leading: UiIcon.flash(),
          title: Text(AppStrings.xpValue(progress.xp), style: UiText.p),
          subtitle: Text(AppStrings.level(progress.level), style: UiText.label),
        ),
        ListTile(
          leading: UiIcon.correct(),
          title: Text(
            AppStrings.completedLessons(progress.completedLessonIds.length),
            style: UiText.p,
          ),
        ),
        const SizedBox(height: UiSpacing.md),
        if (!isAuthenticated)
          AppButton(label: AppStrings.saveMyProgress, onPressed: _openLogin)
        else ...[
          Text(
            ServiceRegistry.auth.providerLabel ?? AppStrings.connectedAccount,
            style: UiText.label,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UiSpacing.sm),
          TextButton(
            onPressed: _confirmSignOut,
            child: const Text(AppStrings.signOut),
          ),
        ],
        const SizedBox(height: UiSpacing.md),
        TextButton(
          onPressed: _showPreferences,
          child: const Text(AppStrings.preferences),
        ),
      ],
    );
  }

  Future<void> _openLogin() async {
    if (!ProductConfig.authenticationEnabled) {
      await AppBottomSheet.show<void>(
        context,
        title: AppStrings.saveMyProgress,
        content: const Text(AppStrings.authUnavailable, style: UiText.p),
      );
      return;
    }
    final authenticated = await showLoginBottomSheet(
      context,
      const LoginRequest(
        context: LoginContext.profile,
        returnLocation: '/profile',
      ),
    );
    if (authenticated && mounted) setState(() {});
  }

  Future<void> _confirmSignOut() async {
    await AppBottomSheet.show<void>(
      context,
      title: AppStrings.signOutTitle,
      content: const Text(AppStrings.signOutDescription, style: UiText.p),
      actions: [
        AppButton(
          label: AppStrings.stayConnected,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: () async {
            await ServiceRegistry.auth.signOut();
            if (!mounted) return;
            Navigator.of(context).pop();
            setState(() {});
          },
          child: const Text(AppStrings.signOut),
        ),
      ],
    );
  }

  Future<void> _showPreferences() async {
    var preferences = ServiceRegistry.preferences.load();
    await AppBottomSheet.show<void>(
      context,
      title: AppStrings.preferences,
      content: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          children: [
            _PreferenceRow(
              title: AppStrings.narrationPreference,
              description: AppStrings.narrationPreferenceDescription,
              value: preferences.narrationEnabled,
              onChanged: (value) async {
                await ServiceRegistry.preferences.setNarrationEnabled(value);
                preferences = preferences.copyWith(narrationEnabled: value);
                setSheetState(() {});
              },
            ),
            _PreferenceRow(
              title: AppStrings.reducedMotionPreference,
              description: AppStrings.reducedMotionPreferenceDescription,
              value: preferences.reducedMotion,
              onChanged: (value) async {
                await ServiceRegistry.preferences.setReducedMotion(value);
                preferences = preferences.copyWith(reducedMotion: value);
                setSheetState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
    toggled: value,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: UiSize.touchTarget),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: UiText.p),
                Text(description, style: UiText.label),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    ),
  );
}
