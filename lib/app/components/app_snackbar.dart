import 'package:flutter/material.dart';

import '../../ui/ui_bottom_sheet.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';

enum AppSnackBarType { info, success, error }

abstract final class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.fixed,
        backgroundColor: UiColor.surfaceElevated,
        elevation: 0,
        padding: EdgeInsets.zero,
        duration: duration,
        content: Container(
          decoration: BoxDecoration(color: UiColor.surfaceElevated),
          padding: const EdgeInsets.fromLTRB(
            UiBottomSheet.horizontalPadding,
            UiSpacing.md,
            UiBottomSheet.horizontalPadding,
            UiSpacing.md,
          ),
          child: SafeArea(
            top: false,
            child: Text(
              message,
              style: UiText.p.copyWith(color: UiColor.accent),
            ),
          ),
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) =>
      show(context, message: message, type: AppSnackBarType.success);

  static void showError(BuildContext context, String message) =>
      show(context, message: message, type: AppSnackBarType.error);
}
