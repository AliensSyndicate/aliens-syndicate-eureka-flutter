import '../enums/social_event_type.dart';
import '../interfaces/repository_social.dart';
import '../models/social/model_ranking_entry.dart';
import '../models/social/model_social_post.dart';
import '../models/social/model_user_preview.dart';
import '../ui/ui_color.dart';

class MockSocialRepository implements SocialRepository {
  MockSocialRepository({DateTime? now}) : _now = now ?? DateTime.now() {
    _posts = _buildPosts();
  }
  final DateTime _now;
  late final List<SocialPost> _posts;
  static const users = [
    UserPreview(
      id: 'maria',
      displayName: 'Maria',
      avatarColor: UiColor.mathematics,
      xp: 4210,
    ),
    UserPreview(
      id: 'joao',
      displayName: 'João',
      avatarColor: UiColor.science,
      xp: 3980,
    ),
    UserPreview(
      id: 'ana',
      displayName: 'Ana',
      avatarColor: UiColor.portuguese,
      xp: 3760,
    ),
    UserPreview(
      id: 'lucas',
      displayName: 'Lucas',
      avatarColor: UiColor.history,
      xp: 3540,
    ),
    UserPreview(
      id: 'bianca',
      displayName: 'Bianca',
      avatarColor: UiColor.science,
      xp: 3370,
    ),
    UserPreview(
      id: 'pedro',
      displayName: 'Pedro',
      avatarColor: UiColor.geography,
      xp: 3200,
    ),
  ];

  List<SocialPost> _buildPosts() {
    const titles = [
      (
        'Conquistou Ouro em Frações!',
        'Matemática · 5º ano',
        SocialEventType.badgeUnlocked,
      ),
      (
        'Terminou Ciências com 94%!',
        'Sistema Solar',
        SocialEventType.highScore,
      ),
      (
        'Subiu para a 8ª posição no ranking!',
        'Ranking do 5º ano',
        SocialEventType.rankingPositionImproved,
      ),
      (
        'Completou 7 dias estudando no Eureka!',
        null,
        SocialEventType.studyStreak,
      ),
      (
        'Terminou o simulado com 87%!',
        'Simulado geral · 5º ano',
        SocialEventType.simulationCompleted,
      ),
      ('Chegou a 5.000 XP!', null, SocialEventType.xpMilestone),
    ];
    return List.generate(28, (index) {
      final item = titles[index % titles.length];
      return SocialPost(
        id: 'post_$index',
        user: users[index % users.length],
        type: item.$3,
        title: item.$1,
        subtitle: item.$2,
        createdAt: _now.subtract(Duration(hours: index * 5 + 2)),
        likesCount: 4 + index,
        likedByCurrentUser: false,
        recentLikes: [
          users[(index + 1) % users.length],
          users[(index + 2) % users.length],
        ],
        layout: index % 5 == 0
            ? SocialPostLayout.featured
            : index.isEven
            ? SocialPostLayout.standard
            : SocialPostLayout.compact,
      );
    });
  }

  @override
  Future<SocialFeedPage> loadFeed({
    required int page,
    int pageSize = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final start = page * pageSize;
    if (start >= _posts.length) {
      return const SocialFeedPage(posts: [], hasMore: false);
    }
    final end = (start + pageSize).clamp(0, _posts.length);
    return SocialFeedPage(
      posts: List.unmodifiable(_posts.sublist(start, end)),
      hasMore: end < _posts.length,
    );
  }

  @override
  Future<void> setPostLiked(String postId, {required bool liked}) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<List<UserPreview>> loadLikes(String postId) async => users;
  @override
  Future<List<UserPreview>> loadFriends() async => users;
  @override
  Future<List<UserPreview>> searchUsers(String query) async {
    final normalized = query.trim().toLowerCase();
    return users
        .where((user) => user.displayName.toLowerCase().contains(normalized))
        .toList();
  }

  @override
  Future<List<RankingEntry>> loadRanking({required int schoolYear}) async =>
      List.generate(20, (index) {
        final user = users[index % users.length];
        return RankingEntry(
          position: index + 1,
          user: UserPreview(
            id: '${user.id}_$index',
            displayName: index == 7 ? 'Você' : user.displayName,
            avatarColor: user.avatarColor,
            xp: 5200 - index * 145,
          ),
          isCurrentUser: index == 7,
        );
      });
}
