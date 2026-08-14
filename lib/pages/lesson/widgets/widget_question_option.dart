import 'package:flutter/material.dart';
import '../../../app/components/app_card.dart';
import '../../../ui/ui_spacing.dart';

class QuestionOption extends StatelessWidget {
  const QuestionOption({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? Theme.of(context).colorScheme.primary : null,
          ),
          const SizedBox(width: UiSpacing.sm),
          Expanded(child: Text(label)),
        ],
      ),
    ),
  );
}
