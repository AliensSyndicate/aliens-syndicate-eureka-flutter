import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../models/explore/model_search_filter.dart';
import '../../../models/explore/model_search_result.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';
import 'widget_filter_chips.dart';
import 'widget_search_result_item.dart';

/// Lista de resultados de busca com botão de filtro discreto.
class SearchResultList extends StatelessWidget {
  const SearchResultList({
    required this.results,
    required this.onTap,
    required this.filter,
    required this.onFilterTap,
    required this.onRemoveSubjectFilter,
    required this.onRemoveYearFilter,
    super.key,
  });

  final List<SearchResult> results;
  final ValueChanged<SearchResult> onTap;
  final SearchFilter? filter;
  final VoidCallback onFilterTap;
  final VoidCallback onRemoveSubjectFilter;
  final VoidCallback onRemoveYearFilter;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Cabeçalho: contagem + botão de filtro
      Padding(
        padding: const EdgeInsets.fromLTRB(
          UiSpacing.pageHorizontal,
          UiSpacing.md,
          UiSpacing.pageHorizontal,
          UiSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${results.length} resultado${results.length == 1 ? '' : 's'}',
                style: UiText.label,
              ),
            ),
            // Botão de filtro discreto
            GestureDetector(
              onTap: onFilterTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.tune_rounded,
                    size: UiSize.iconSm,
                    color: UiColor.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppStrings.exploreFilterSubject,
                    style: UiText.small.copyWith(color: UiColor.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Chips de filtros ativos
      if (filter != null && filter!.isActive) ...[
        FilterChips(
          filter: filter!,
          onRemoveSubject: onRemoveSubjectFilter,
          onRemoveYear: onRemoveYearFilter,
        ),
        const SizedBox(height: UiSpacing.xs),
      ],
      // Lista de resultados
      ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: results.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          indent: UiSpacing.pageHorizontal + UiSize.iconLg + UiSpacing.md,
          endIndent: UiSpacing.pageHorizontal,
          color: UiColor.divider.withValues(alpha: .5),
        ),
        itemBuilder: (_, i) => SearchResultItem(
          result: results[i],
          onTap: () => onTap(results[i]),
        ),
      ),
    ],
  );
}
