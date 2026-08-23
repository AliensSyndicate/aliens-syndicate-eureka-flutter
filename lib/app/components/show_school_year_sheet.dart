import 'package:flutter/material.dart';

import '../../l10n/app_strings.dart';
import '../../ui/ui_bottom_sheet.dart';
import '../../ui/ui_card.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_icon.dart';
import '../../ui/ui_radius.dart';
import '../../ui/ui_size.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';

/// Abre o sheet de escolha de turma e retorna o ano letivo selecionado.
///
/// [availableYears] lista os anos com conteúdo habilitado — apenas eles
/// aparecem na lista.
/// Retorna [null] se o usuário fechar sem selecionar.
Future<int?> showSchoolYearSheet(
  BuildContext context, {
  required int currentYear,
  required List<int> availableYears,
}) {
  // Mesmo contrato de margem do AppBottomSheet.
  final statusBarHeight = MediaQuery.of(context).padding.top;
  final screenHeight = MediaQuery.of(context).size.height;
  final maxSheetHeight = screenHeight - statusBarHeight;

  return showModalBottomSheet<int>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    constraints: BoxConstraints(maxHeight: maxSheetHeight),
    builder: (context) => SafeArea(
      top: false,
      child: Column(
        // mainAxisSize.min → o sheet só ocupa o espaço do conteúdo.
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabeçalho fixo
          Padding(
            padding: const EdgeInsets.fromLTRB(
              UiBottomSheet.horizontalPadding,
              UiBottomSheet.topPadding,
              UiBottomSheet.horizontalPadding,
              UiSpacing.md,
            ),
            child: Semantics(
              header: true,
              child: Text(
                AppStrings.turmaTitle,
                style: UiText.h4.copyWith(color: UiColor.accent),
              ),
            ),
          ),

          // Lista rolável de anos — filtra por availableYears.
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                UiBottomSheet.horizontalPadding,
                0,
                UiBottomSheet.horizontalPadding,
                UiBottomSheet.bottomPadding +
                    MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Grupo EF (1–9) — exibido apenas se houver anos disponíveis
                  ...() {
                    final efYears = List.generate(9, (i) => i + 1)
                        .where(availableYears.contains)
                        .toList();
                    if (efYears.isEmpty) return const <Widget>[];
                    return [
                      _SectionLabel(AppStrings.stageElementarySchoolFull),
                      const SizedBox(height: UiSpacing.xs),
                      _YearGroup(years: efYears, currentYear: currentYear),
                      const SizedBox(height: UiSpacing.md),
                    ];
                  }(),
                  // Grupo EM (10–12) — exibido apenas se houver anos disponíveis
                  ...() {
                    final emYears = List.generate(3, (i) => i + 10)
                        .where(availableYears.contains)
                        .toList();
                    if (emYears.isEmpty) return const <Widget>[];
                    return [
                      _SectionLabel(AppStrings.stageHighSchoolFull),
                      const SizedBox(height: UiSpacing.xs),
                      _YearGroup(years: emYears, currentYear: currentYear),
                    ];
                  }(),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Label de seção
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: UiText.label.copyWith(
      color: UiColor.textSecondary,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
    ),
  );
}

// ---------------------------------------------------------------------------
// Grupo de anos — card com borda e divisores (igual ao CurriculumYearSection)
// ---------------------------------------------------------------------------

class _YearGroup extends StatelessWidget {
  const _YearGroup({required this.years, required this.currentYear});

  final List<int> years;
  final int currentYear;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(UiRadius.card),
      border: Border.all(color: UiColor.outline, width: UiCard.borderWidth),
    ),
    child: Column(
      children: years.indexed.expand((entry) {
        final (index, year) = entry;
        final isFirst = index == 0;
        final isLast = index == years.length - 1;
        // Raio de cada canto: arredondado apenas nas extremidades do grupo.
        final radius = BorderRadius.only(
          topLeft: isFirst ? const Radius.circular(UiRadius.card) : Radius.zero,
          topRight: isFirst ? const Radius.circular(UiRadius.card) : Radius.zero,
          bottomLeft: isLast ? const Radius.circular(UiRadius.card) : Radius.zero,
          bottomRight: isLast ? const Radius.circular(UiRadius.card) : Radius.zero,
        );
        return [
          _YearTile(
            year: year,
            isSelected: year == currentYear,
            borderRadius: radius,
          ),
          if (!isLast)
            const Divider(height: 1, thickness: 1, color: UiColor.divider),
        ];
      }).toList(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tile de ano — mochila + label + chevron/check (igual ao _ContentItem)
// ---------------------------------------------------------------------------

class _YearTile extends StatelessWidget {
  const _YearTile({
    required this.year,
    required this.isSelected,
    required this.borderRadius,
  });

  final int year;
  final bool isSelected;
  final BorderRadius borderRadius;

  String get _label => year <= 9
      ? AppStrings.stageElementarySchoolYear(year)
      : AppStrings.stageHighSchoolYear(year - 9);

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: isSelected,
    label: _label,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: isSelected
            ? Border.all(color: UiColor.accent, width: UiCard.borderWidth)
            : null,
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).pop(year),
        borderRadius: borderRadius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: UiCard.subjectHeight),
          child: Row(
            children: [
              const SizedBox(width: UiSpacing.md),
              UiIcon.backpackForYear(year, size: UiSize.iconMd),
              const SizedBox(width: UiSpacing.sm),
              Expanded(
                child: Text(
                  _label,
                  style: UiText.p.copyWith(
                    color: isSelected ? UiColor.accent : UiColor.text,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: UiSpacing.md),
            ],
          ),
        ),
      ),
    ),
  );
}
