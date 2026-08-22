import '../models/social/model_ranking_entry.dart';
import '../models/social/model_social_post.dart';
import '../models/social/model_user_preview.dart';

abstract interface class SocialRepository {
  Future<SocialFeedPage> loadFeed({required int page, int pageSize = 20});
  Future<void> setPostLiked(String postId, {required bool liked});
  Future<List<UserPreview>> loadLikes(String postId);
  Future<List<UserPreview>> loadFriends();
  Future<List<UserPreview>> searchUsers(String query);
  Future<List<RankingEntry>> loadRanking({required int schoolYear});
}
