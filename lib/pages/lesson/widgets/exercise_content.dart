import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../services/service_lesson_narration.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class ExerciseContent extends StatefulWidget {
  const ExerciseContent({
    required this.title,
    required this.description,
    required this.primaryColor,
    this.notice,
    this.narrationController,
    super.key,
  });

  final String title;
  final String description;
  final Color primaryColor;
  final String? notice;
  final LessonNarrationController? narrationController;

  @override
  State<ExerciseContent> createState() => _ExerciseContentState();
}

class _ExerciseContentState extends State<ExerciseContent> {
  late final LessonNarrationController narrationController;
  late final bool ownsNarrationController;

  @override
  void initState() {
    super.initState();
    ownsNarrationController = widget.narrationController == null;
    narrationController =
        widget.narrationController ?? LessonNarrationService();
  }

  @override
  void didUpdateWidget(covariant ExerciseContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.description != widget.description) {
      unawaited(narrationController.stop());
    }
  }

  @override
  void dispose() {
    if (ownsNarrationController) {
      narrationController.dispose();
    } else {
      unawaited(narrationController.stop());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AnimatedBuilder(
        animation: narrationController,
        builder: (context, child) {
          final playing =
              narrationController.state == LessonNarrationState.playing;
          final actionLabel = playing
              ? AppStrings.pauseLessonAudio
              : AppStrings.playLessonAudio;
          return Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: UiText.h5.copyWith(color: widget.primaryColor),
                ),
              ),
              const SizedBox(width: UiSpacing.sm),
              IconButton(
                key: const ValueKey('lesson-narration-toggle'),
                tooltip: actionLabel,
                constraints: const BoxConstraints.tightFor(
                  width: UiSize.touchTarget,
                  height: UiSize.touchTarget,
                ),
                onPressed: () => narrationController.toggle(widget.description),
                icon: playing
                    ? UiIcon.pause(
                        size: UiSize.iconMd,
                        color: widget.primaryColor,
                      )
                    : UiIcon.play(
                        size: UiSize.iconMd,
                        color: widget.primaryColor,
                      ),
              ),
            ],
          );
        },
      ),
      const SizedBox(height: UiSpacing.xs),
      Text(widget.description, style: UiText.p),
      if (widget.notice != null) ...[
        const SizedBox(height: UiSpacing.xxl),
        Text(
          widget.notice!,
          textAlign: TextAlign.center,
          style: UiText.p.copyWith(color: UiColor.textSecondary),
        ),
      ],
    ],
  );
}
