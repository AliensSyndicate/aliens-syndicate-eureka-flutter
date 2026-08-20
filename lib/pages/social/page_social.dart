import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_icon.dart';
import '../../ui/ui_size.dart';

class PageSocial extends StatelessWidget {
  const PageSocial({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(UiSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UiIcon.trophy(size: UiSize.avatar),
          const SizedBox(height: UiSpacing.md),
          const Text(AppStrings.socialSoon, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
