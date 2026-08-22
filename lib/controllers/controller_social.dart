import 'package:flutter/foundation.dart';
import '../interfaces/repository_social.dart';
import '../models/social/model_social_post.dart';

enum SocialFeedStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  refreshing,
  empty,
  error,
}

class SocialController extends ChangeNotifier {
  SocialController(this._repository);
  final SocialRepository _repository;
  final List<SocialPost> _posts = [];
  SocialFeedStatus status = SocialFeedStatus.initial;
  Object? error;
  bool hasMore = true;
  int _page = 0;
  bool _busy = false;
  List<SocialPost> get posts => List.unmodifiable(_posts);
  SocialRepository get repository => _repository;

  Future<void> loadInitial() async {
    if (_busy) return;
    _busy = true;
    status = SocialFeedStatus.loading;
    error = null;
    notifyListeners();
    try {
      final result = await _repository.loadFeed(page: 0);
      _posts
        ..clear()
        ..addAll(result.posts);
      _page = 0;
      hasMore = result.hasMore;
      status = _posts.isEmpty
          ? SocialFeedStatus.empty
          : SocialFeedStatus.loaded;
    } catch (caught) {
      error = caught;
      status = SocialFeedStatus.error;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_busy) return;
    _busy = true;
    status = SocialFeedStatus.refreshing;
    notifyListeners();
    try {
      final result = await _repository.loadFeed(page: 0);
      _posts
        ..clear()
        ..addAll(result.posts);
      _page = 0;
      hasMore = result.hasMore;
      error = null;
      status = _posts.isEmpty
          ? SocialFeedStatus.empty
          : SocialFeedStatus.loaded;
    } catch (caught) {
      error = caught;
      status = _posts.isEmpty
          ? SocialFeedStatus.error
          : SocialFeedStatus.loaded;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_busy || !hasMore || _posts.isEmpty) return;
    _busy = true;
    status = SocialFeedStatus.loadingMore;
    notifyListeners();
    try {
      final result = await _repository.loadFeed(page: _page + 1);
      final known = _posts.map((post) => post.id).toSet();
      _posts.addAll(result.posts.where((post) => !known.contains(post.id)));
      _page++;
      hasMore = result.hasMore;
      error = null;
    } catch (caught) {
      error = caught;
    } finally {
      _busy = false;
      status = SocialFeedStatus.loaded;
      notifyListeners();
    }
  }

  Future<void> toggleLike(String postId) async {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index < 0) return;
    final previous = _posts[index];
    final liked = !previous.likedByCurrentUser;
    _posts[index] = previous.copyWith(
      likedByCurrentUser: liked,
      likesCount: (previous.likesCount + (liked ? 1 : -1)).clamp(0, 1 << 31),
    );
    notifyListeners();
    try {
      await _repository.setPostLiked(postId, liked: liked);
    } catch (caught) {
      _posts[index] = previous;
      error = caught;
      notifyListeners();
    }
  }
}
