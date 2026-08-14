import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_size.dart';

class PageSocial extends StatelessWidget {
  const PageSocial({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(UiSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, size: UiSize.avatar),
          SizedBox(height: UiSpacing.md),
          Text(AppStrings.socialSoon, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
