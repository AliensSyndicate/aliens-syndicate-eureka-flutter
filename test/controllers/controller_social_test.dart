import 'package:eureka/controllers/controller_social.dart';
import 'package:eureka/enums/social_event_type.dart';
import 'package:eureka/interfaces/repository_social.dart';
import 'package:eureka/models/social/model_ranking_entry.dart';
import 'package:eureka/models/social/model_social_post.dart';
import 'package:eureka/models/social/model_user_preview.dart';
import 'package:eureka/ui/ui_color.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('carrega, pagina e faz curtida otimista', () async {
    final repository = _FakeRepository();
    final controller = SocialController(repository);
    await controller.loadInitial();
    expect(controller.posts, hasLength(1));
    expect(controller.status, SocialFeedStatus.loaded);
    final like = controller.toggleLike('1');
    expect(controller.posts.single.likedByCurrentUser, isTrue);
    expect(controller.posts.single.likesCount, 2);
    await like;
    await controller.loadMore();
    expect(controller.posts, hasLength(2));
    expect(controller.hasMore, isFalse);
  });
  test('reverte curtida quando o repository falha', () async {
    final repository = _FakeRepository(failLike: true);
    final controller = SocialController(repository);
    await controller.loadInitial();
    await controller.toggleLike('1');
    expect(controller.posts.single.likedByCurrentUser, isFalse);
    expect(controller.posts.single.likesCount, 1);
  });
}

class _FakeRepository implements SocialRepository {
  _FakeRepository({this.failLike = false});
  final bool failLike;
  static const user = UserPreview(
    id: 'u',
    displayName: 'Maria',
    avatarColor: UiColor.accent,
  );
  SocialPost post(String id) => SocialPost(
    id: id,
    user: user,
    type: SocialEventType.badgeUnlocked,
    title: 'Conquistou Ouro!',
    createdAt: DateTime(2026),
    likesCount: 1,
    likedByCurrentUser: false,
  );
  @override
  Future<SocialFeedPage> loadFeed({
    required int page,
    int pageSize = 20,
  }) async => SocialFeedPage(posts: [post('${page + 1}')], hasMore: page == 0);
  @override
  Future<void> setPostLiked(String postId, {required bool liked}) async {
    if (failLike) throw StateError('offline');
  }

  @override
  Future<List<UserPreview>> loadLikes(String postId) async => [user];
  @override
  Future<List<UserPreview>> loadFriends() async => [user];
  @override
  Future<List<UserPreview>> searchUsers(String query) async => [user];
  @override
  Future<List<RankingEntry>> loadRanking({required int schoolYear}) async =>
      const [];
}
