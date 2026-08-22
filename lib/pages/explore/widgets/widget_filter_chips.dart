import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../models/explore/model_search_filter.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

/// Chips de filtros ativos exibidos abaixo da busca.
///
/// Exemplo: `Matemática ×`  `5º ano ×`
class FilterChips extends StatelessWidget {
  const FilterChips({
    required this.filter,
    required this.onRemoveSubject,
    required this.onRemoveYear,
    super.key,
  });

  final SearchFilter filter;
  final VoidCallback onRemoveSubject;
  final VoidCallback onRemoveYear;

  @override
  Widget build(BuildContext context) {
    if (!filter.isActive) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UiSpacing.pageHorizontal),
      child: Wrap(
        spacing: UiSpacing.xs,
        runSpacing: UiSpacing.xs,
        children: [
          if (filter.subject != null)
            _Chip(
              label: AppStrings.subjectName(filter.subject!),
              onRemove: onRemoveSubject,
            ),
          if (filter.schoolYear != null)
            _Chip(
              label: AppStrings.schoolYear(filter.schoolYear!),
              onRemove: onRemoveYear,
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onRemove,
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UiSpacing.sm,
        vertical: UiSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: UiColor.accent.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: UiColor.accent.withValues(alpha: .35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: UiText.small.copyWith(
              color: UiColor.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.close, size: 14, color: UiColor.accent),
        ],
      ),
    ),
  );
}
