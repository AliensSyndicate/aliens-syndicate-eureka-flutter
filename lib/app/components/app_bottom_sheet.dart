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
  }) => showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          UiBottomSheet.horizontalPadding,
          UiBottomSheet.topPadding,
          UiBottomSheet.horizontalPadding,
          MediaQuery.viewInsetsOf(context).bottom + UiBottomSheet.bottomPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                style: UiText.h4.copyWith(color: UiColor.accent),
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
