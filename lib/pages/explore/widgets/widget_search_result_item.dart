import 'package:flutter/material.dart';

import '../../../enums/subject_type.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/explore/model_search_result.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

/// Item de resultado de busca — linha limpa sem card com sombra.
///
/// Estrutura visual:
/// ```
/// [ícone]  Título da lição
///          Matéria · Xº ano
///          Descrição breve (opcional)
/// ─────────────────────────────────────
/// ```
class SearchResultItem extends StatelessWidget {
  const SearchResultItem({
    required this.result,
    required this.onTap,
    super.key,
  });

  final SearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = UiColor.forSubject(result.subjectType);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UiSpacing.pageHorizontal,
          vertical: UiSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone da matéria
            Container(
              width: UiSize.iconLg,
              height: UiSize.iconLg,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: _subjectIcon(result.subjectType),
            ),
            const SizedBox(width: UiSpacing.md),
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    style: UiText.p.copyWith(
                      fontWeight: FontWeight.w700,
                      color: UiColor.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${result.subjectName} · ${AppStrings.schoolYear(result.schoolYear)}',
                    style: UiText.small.copyWith(color: color),
                  ),
                  if (result.description != null &&
                      result.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      result.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: UiText.small.copyWith(
                        color: UiColor.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subjectIcon(SubjectType type) {
    const size = UiSize.iconMd;
    return switch (type) {
      SubjectType.mathematics => UiIcon.subjectMath(size: size),
      SubjectType.portuguese => UiIcon.subjectPortuguese(size: size),
      SubjectType.geography => UiIcon.subjectGeography(size: size),
      SubjectType.science => UiIcon.subjectScience(size: size),
      SubjectType.biology => UiIcon.subjectBiology(size: size),
      SubjectType.physics => UiIcon.subjectPhysics(size: size),
      SubjectType.history => UiIcon.subjectHistory(size: size),
      _ => UiIcon.subjectPortuguese(size: size),
    };
  }
}
