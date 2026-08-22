import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

/// Seção "Buscas recentes" com chips tocáveis e botão Limpar.
class RecentSearches extends StatelessWidget {
  const RecentSearches({
    required this.queries,
    required this.onTap,
    required this.onClear,
    super.key,
  });

  final List<String> queries;
  final ValueChanged<String> onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (queries.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UiSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(AppStrings.exploreRecentSearches, style: UiText.h6),
              ),
              GestureDetector(
                onTap: onClear,
                child: Text(
                  AppStrings.exploreClearHistory,
                  style: UiText.small.copyWith(color: UiColor.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: UiSpacing.sm),
          Wrap(
            spacing: UiSpacing.xs,
            runSpacing: UiSpacing.xs,
            children: queries
                .map(
                  (q) => GestureDetector(
                    onTap: () => onTap(q),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: UiSpacing.md,
                        vertical: UiSpacing.xxs + 2,
                      ),
                      decoration: BoxDecoration(
                        color: UiColor.surfaceElevated,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        q,
                        style: UiText.small.copyWith(
                          color: UiColor.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
