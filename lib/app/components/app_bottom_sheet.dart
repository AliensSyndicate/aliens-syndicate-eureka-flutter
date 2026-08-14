import 'package:flutter/material.dart';
import '../../ui/ui_spacing.dart';

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
          UiSpacing.lg,
          UiSpacing.md,
          UiSpacing.lg,
          MediaQuery.viewInsetsOf(context).bottom + UiSpacing.lg,
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
