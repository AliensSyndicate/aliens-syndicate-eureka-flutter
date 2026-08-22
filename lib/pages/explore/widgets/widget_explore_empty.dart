import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

/// Estado vazio do Explorar — sem resultados para a query.
///
/// Intencionalmente simples: sem ícone gigante, sem bordas, sem background especial.
class ExploreEmpty extends StatelessWidget {
  const ExploreEmpty({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: UiSpacing.pageHorizontal,
      vertical: UiSpacing.xxxl,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppStrings.exploreEmptyTitle,
          textAlign: TextAlign.center,
          style: UiText.h5,
        ),
        const SizedBox(height: UiSpacing.xs),
        Text(
          AppStrings.exploreEmptySubtitle,
          textAlign: TextAlign.center,
          style: UiText.p.copyWith(color: UiColor.textSecondary),
        ),
      ],
    ),
  );
}
