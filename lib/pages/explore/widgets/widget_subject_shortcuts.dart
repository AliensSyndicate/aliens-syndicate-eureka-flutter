import 'package:flutter/material.dart';

import '../../../enums/subject_type.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/content/model_content_manifest.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

/// Grid de atalhos "Explore por matéria".
///
/// Exibe um grid 2×N com ícone e nome de cada matéria disponível.
class SubjectShortcuts extends StatelessWidget {
  const SubjectShortcuts({
    required this.subjects,
    required this.onTap,
    super.key,
  });

  final List<SubjectContentManifest> subjects;
  final ValueChanged<SubjectContentManifest> onTap;

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UiSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.exploreBySubject, style: UiText.h6),
          const SizedBox(height: UiSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: UiSpacing.sm,
              mainAxisSpacing: UiSpacing.sm,
              childAspectRatio: 2.8,
            ),
            itemCount: subjects.length,
            itemBuilder: (_, i) => _SubjectTile(
              subject: subjects[i],
              onTap: () => onTap(subjects[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({required this.subject, required this.onTap});

  final SubjectContentManifest subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = UiColor.forSubject(subject.type);

    return Material(
      color: UiColor.surfaceElevated,
      borderRadius: BorderRadius.circular(UiRadius.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UiSpacing.md,
            vertical: UiSpacing.sm,
          ),
          child: Row(
            children: [
              _subjectIcon(subject.type),
              const SizedBox(width: UiSpacing.xs),
              Expanded(
                child: Text(
                  subject.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiText.small.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _subjectIcon(SubjectType type) {
    const size = UiSize.iconSm;
    return switch (type) {
      SubjectType.mathematics => UiIcon.subjectMath(size: size),
      SubjectType.portuguese => UiIcon.subjectPortuguese(size: size),
      SubjectType.geography => UiIcon.subjectGeography(size: size),
      SubjectType.science => UiIcon.subjectScience(size: size),
      SubjectType.biology => UiIcon.subjectBiology(size: size),
      SubjectType.physics => UiIcon.subjectPhysics(size: size),
      SubjectType.history => UiIcon.subjectHistory(size: size),
      SubjectType.english => UiIcon.subjectEnglish(size: size),
      SubjectType.spanish => UiIcon.subjectSpanish(size: size),
      _ => UiIcon.subjectPortuguese(size: size),
    };
  }
}
