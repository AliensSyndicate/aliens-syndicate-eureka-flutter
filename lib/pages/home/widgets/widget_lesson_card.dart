import 'package:flutter/material.dart';
import '../../../app/components/app_card.dart';
import '../../../models/model_lesson.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_spacing.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({required this.lesson, required this.onTap, super.key});
  final Lesson lesson;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final color = UiColor.forSubject(lesson.subject);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome_rounded, color: color),
          ),
          const SizedBox(width: UiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: UiSpacing.xs),
                Text(
                  lesson.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
