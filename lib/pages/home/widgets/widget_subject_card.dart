import 'package:flutter/material.dart';

import '../../../models/content/model_content_manifest.dart';
import '../../../ui/ui_card.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_gradient.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class SubjectCard extends StatelessWidget {
  const SubjectCard({
    required this.subject,
    required this.progress,
    required this.onTap,
    super.key,
  });
  final SubjectContentManifest subject;
  final int progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = UiColor.forSubject(subject.type);
    return Padding(
      padding: const EdgeInsets.only(bottom: UiSpacing.sm),
      child: Material(
        color: color,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiRadius.card),
          side: BorderSide(
            color: UiColor.subjectBorder(subject.type),
            width: UiCard.highlightBorderWidth,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: UiGradient.forSubject(subject.type),
            ),
            child: SizedBox(
              height: UiCard.subjectHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: UiSpacing.xl),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        subject.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UiText.h5.copyWith(
                          color: UiColor.background,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      height: UiCard.progressTagHeight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: UiSpacing.md,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: UiColor.text.withValues(alpha: .24),
                        borderRadius: BorderRadius.circular(UiRadius.pill),
                      ),
                      child: Text(
                        '$progress%',
                        style: UiText.label.copyWith(
                          color: UiColor.background,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: UiSpacing.sm),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: UiSize.iconLg,
                      color: UiColor.background,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
