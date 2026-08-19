import 'package:eureka/enums/subject_type.dart';
import 'package:flutter/material.dart';

import '../../../models/content/model_content_manifest.dart';
import '../../../ui/ui_card.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_icon.dart';
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

  Widget _getSubjectIcon(Color color) {
    switch (subject.type) {
      case SubjectType.mathematics:
        return UiIcon.subjectMath(size: UiSize.icon, onlyHeight: true);
      case SubjectType.geography:
        return UiIcon.subjectGeography(size: UiSize.icon, onlyHeight: true);
      case SubjectType.science:
        return UiIcon.subjectScience(size: UiSize.icon, onlyHeight: true);
      case SubjectType.biology:
        return UiIcon.subjectBiology(size: UiSize.icon, onlyHeight: true);
      case SubjectType.physics:
        return UiIcon.subjectPhysics(size: UiSize.icon, onlyHeight: true);
      case SubjectType.history:
        return UiIcon.subjectHistory(size: UiSize.icon, onlyHeight: true);
      case SubjectType.english:
        return UiIcon.subjectEnglish(size: UiSize.icon, onlyHeight: true);
      case SubjectType.spanish:
        return UiIcon.subjectSpanish(size: UiSize.icon, onlyHeight: true);
      default:
        return UiIcon.subjectPortuguese(size: UiSize.icon, onlyHeight: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectColor = UiColor.forSubject(subject.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: UiSpacing.sm),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiRadius.card),
          side: BorderSide(
            color: UiColor.subjectBorder(subject.type).withValues(alpha: .90),
            width: UiCard.subjectBorderWidth,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Ink(
            color: Colors.transparent,
            child: SizedBox(
              height: UiCard.subjectHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: UiSpacing.xl),
                child: Row(
                  children: [
                    _getSubjectIcon(subjectColor),
                    const SizedBox(width: UiSpacing.md),
                    Expanded(
                      child: Text(
                        subject.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UiText.h5.copyWith(
                          color: subjectColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '$progress%',
                      style: UiText.h6.copyWith(color: subjectColor),
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
