import 'package:flutter/material.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_option.dart';
import '../../../ui/ui_spacing.dart';

enum QuestionOptionState { normal, selected, correct, incorrect, disabled }

class QuestionOption extends StatelessWidget {
  const QuestionOption({
    required this.label,
    required this.selected,
    required this.onTap,
    this.state,
    super.key,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final QuestionOptionState? state;

  @override
  Widget build(BuildContext context) {
    final current =
        state ??
        (selected ? QuestionOptionState.selected : QuestionOptionState.normal);
    final accent = switch (current) {
      QuestionOptionState.selected => UiColor.primary,
      QuestionOptionState.correct => UiColor.success,
      QuestionOptionState.incorrect => UiColor.error,
      _ => UiColor.outline,
    };
    final disabled = current == QuestionOptionState.disabled;
    return Padding(
      padding: const EdgeInsets.only(bottom: UiSpacing.sm),
      child: Semantics(
        selected: selected,
        button: true,
        enabled: !disabled,
        child: Opacity(
          opacity: disabled ? .55 : 1,
          child: Material(
            color: current == QuestionOptionState.normal || disabled
                ? UiColor.surface
                : accent.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(UiOption.radius),
            child: InkWell(
              onTap: disabled ? null : onTap,
              borderRadius: BorderRadius.circular(UiOption.radius),
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: UiOption.minHeight,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: UiOption.paddingHorizontal,
                  vertical: UiOption.paddingVertical,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(UiOption.radius),
                  border: Border.all(
                    color: accent,
                    width: UiOption.borderWidth,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: accent,
                    ),
                    const SizedBox(width: UiSpacing.sm),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
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
