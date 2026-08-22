import 'package:flutter/material.dart';
import '../../models/social/model_ranking_entry.dart';
import '../../repositories/repository_mock_social.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';
import 'widgets/widget_social_avatar.dart';

class PageRanking extends StatefulWidget {
  const PageRanking({super.key});
  @override
  State<PageRanking> createState() => _PageRankingState();
}

class _PageRankingState extends State<PageRanking> {
  List<RankingEntry> entries = const [];
  @override
  void initState() {
    super.initState();
    MockSocialRepository().loadRanking(schoolYear: 5).then((value) {
      if (mounted) setState(() => entries = value);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ranking 2026')),
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              UiSpacing.pageHorizontal,
              UiSpacing.md,
              UiSpacing.pageHorizontal,
              UiSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('5º ano · 1ª divisão', style: UiText.h5),
                const SizedBox(height: UiSpacing.xs),
                Text('20 alunos nesta divisão', style: UiText.label),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (_, index) {
                final entry = entries[index];
                return Container(
                  color: entry.isCurrentUser ? UiColor.surfaceElevated : null,
                  padding: const EdgeInsets.symmetric(
                    horizontal: UiSpacing.pageHorizontal,
                    vertical: UiSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text(
                          '${entry.position}º',
                          style: entry.isCurrentUser
                              ? UiText.h6.copyWith(color: UiColor.accent)
                              : UiText.label,
                        ),
                      ),
                      SocialAvatar(user: entry.user),
                      const SizedBox(width: UiSpacing.sm),
                      Expanded(
                        child: Text(entry.user.displayName, style: UiText.p),
                      ),
                      Text('${entry.user.xp} XP', style: UiText.label),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            color: UiColor.surface,
            padding: const EdgeInsets.all(UiSpacing.md),
            child: Text(
              'Faltam 120 XP para subir de divisão.',
              style: UiText.p,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ),
  );
}
