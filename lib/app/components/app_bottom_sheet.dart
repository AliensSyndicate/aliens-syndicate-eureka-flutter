import 'package:flutter/material.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_bottom_sheet.dart';

class AppBottomSheet {
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    List<Widget> actions = const [],
  }) => showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
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
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
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
