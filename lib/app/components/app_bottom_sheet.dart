import 'package:eureka/ui/ui_color.dart';
import 'package:eureka/ui/ui_text.dart';
import 'package:flutter/material.dart';

import '../../ui/ui_bottom_sheet.dart';
import '../../ui/ui_spacing.dart';

class AppBottomSheet {
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    List<Widget> actions = const [],
    bool isDismissible = true,
    bool enableDrag = true,
    Color titleColor = UiColor.accent,
  }) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxSheetHeight = screenHeight - statusBarHeight;

    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      builder: (context) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            UiBottomSheet.horizontalPadding,
            UiBottomSheet.topPadding,
            UiBottomSheet.horizontalPadding,
            MediaQuery.viewInsetsOf(context).bottom +
                UiBottomSheet.bottomPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: UiText.h4.copyWith(color: titleColor),
                ),
              ),
              const SizedBox(height: UiSpacing.md),
              content,
              if (actions.isNotEmpty) ...[
                const SizedBox(height: UiSpacing.lg),
                ...actions,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
