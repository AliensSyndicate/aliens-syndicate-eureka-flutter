import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/components/app_button.dart';
import '../../app/navigation/navigation_router.dart';
import '../../config/config_product.dart';
import '../../enums/login_context.dart';
import '../../l10n/app_strings.dart';
import '../../models/auth/model_login_request.dart';
import '../../models/model_activity_result.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';
import '../auth/login_bottom_sheet.dart';

class PageActivityResult extends StatefulWidget {
  const PageActivityResult({required this.result, super.key});
  final ActivityResult result;

  @override
  State<PageActivityResult> createState() => _PageActivityResultState();
}

class _PageActivityResultState extends State<PageActivityResult> {
  ActivityResult get result => widget.result;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _offerCloudSave());
  }

  Future<void> _offerCloudSave() async {
    if (!mounted ||
        !ProductConfig.authenticationEnabled ||
        ServiceRegistry.user.isAuthenticated ||
        ServiceRegistry.progress.load().completedLessonIds.length != 1 ||
        ServiceRegistry.preferences.load().saveProgressPromptDismissed) {
      return;
    }
    final authenticated = await showLoginBottomSheet(
      context,
      const LoginRequest(
        context: LoginContext.saveProgress,
        returnLocation: '/lesson/result',
      ),
    );
    if (!authenticated) {
      await ServiceRegistry.preferences.dismissSaveProgressPrompt();
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent = (result.score * 100).round();
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.activityResult)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(UiSpacing.pageHorizontal),
          children: [
            Text('$percent%', style: UiText.h1),
            const SizedBox(height: UiSpacing.xs),
            Text(_message(percent), style: UiText.h5),
            const SizedBox(height: UiSpacing.xxl),
            Text(
              AppStrings.activitiesSummaryResult(
                result.correctAnswers,
                result.totalQuestions,
              ),
              style: UiText.h5,
            ),
            const SizedBox(height: UiSpacing.sm),
            Text(
              AppStrings.activityDuration(result.duration.inMinutes),
              style: UiText.p.copyWith(color: UiColor.textSecondary),
            ),
            if (result.earnedXp > 0) ...[
              const SizedBox(height: UiSpacing.sm),
              Text(
                AppStrings.activityEarnedXp(result.earnedXp),
                style: UiText.p.copyWith(color: UiColor.xp),
              ),
            ],
            if (result.reviewTopics.isNotEmpty) ...[
              const SizedBox(height: UiSpacing.xl),
              Text(
                AppStrings.activityReviewSuggestion,
                style: UiText.p.copyWith(color: UiColor.warning),
              ),
            ],
            const SizedBox(height: UiSpacing.xxl),
            AppButton(
              label: AppStrings.backToHome,
              onPressed: () => context.goNamed(AppRoute.home),
            ),
          ],
        ),
      ),
    );
  }

  static String _message(int percent) => percent >= 90
      ? AppStrings.simulationExcellent
      : percent >= 70
      ? AppStrings.simulationWellDone
      : AppStrings.simulationAlmostThere;
}
