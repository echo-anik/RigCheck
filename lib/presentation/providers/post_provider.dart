import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/post.dart';
import '../../data/models/comment.dart';
import '../../data/repositories/post_repository.dart';
import 'auth_provider.dart';

// Post Repository Provider
final postRepositoryProvider = Provider<PostRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PostRepository(apiClient);
});

// Post State
class PostState {
  final List<Post> feedPosts;
  final Map<int, List<Comment>> commentsByPost;
  final bool isLoading;
  final String? error;

  PostState({
    this.feedPosts = const [],
    this.commentsByPost = const {},
    this.isLoading = false,
    this.error,
  });

  PostState copyWith({
    List<Post>? feedPosts,
    Map<int, List<Comment>>? commentsByPost,
    bool? isLoading,
    String? error,
  }) {
    return PostState(
      feedPosts: feedPosts ?? this.feedPosts,
      commentsByPost: commentsByPost ?? this.commentsByPost,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Post State Notifier
class PostNotifier extends StateNotifier<PostState> {
  final PostRepository _postRepository;

  PostNotifier(this._postRepository) : super(PostState());

  /// Load feed posts
  Future<void> loadFeed({
    int page = 1,
    int perPage = 20,
    bool followedOnly = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final posts = await _postRepository.getFeedPosts(
        page: page,
        perPage: perPage,
        followedOnly: followedOnly,
      );

      state = state.copyWith(
        feedPosts: page == 1 ? posts : [...state.feedPosts, ...posts],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Create a new post
  Future<bool> createPost({
    required String content,
    String? imageUrl,
    int? buildId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _postRepository.createPost(
        content: content,
        imageUrl: imageUrl,
        buildId: buildId,
      );

      if (result['success'] == true) {
        final newPost = result['post'] as Post;
        
        // Add to feed
        state = state.copyWith(
          feedPosts: [newPost, ...state.feedPosts],
          isLoading: false,
        );

        return true;
      } else {
        state = state.copyWith(
          error: result['message'] as String,
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  /// Delete a post
  Future<bool> deletePost(int postId) async {
    try {
      final success = await _postRepository.deletePost(postId);

      if (success) {
        // Remove from feed
        state = state.copyWith(
          feedPosts: state.feedPosts.where((p) => p.id != postId).toList(),
        );
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Toggle like on a post
  Future<bool> toggleLike(int postId) async {
    try {
      final result = await _postRepository.toggleLike(postId);

      if (result['success'] == true) {
        // Update post in feed
        final updatedFeed = state.feedPosts.map((post) {
          if (post.id == postId) {
            return post.copyWith(
              isLikedByUser: result['liked'] as bool,
              likeCount: result['like_count'] as int,
            );
          }
          return post;
        }).toList();

        state = state.copyWith(feedPosts: updatedFeed);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Load comments for a post
  Future<void> loadComments(int postId) async {
    try {
      final comments = await _postRepository.getComments(postId);

      final updatedComments = Map<int, List<Comment>>.from(state.commentsByPost);
      updatedComments[postId] = comments;

      state = state.copyWith(commentsByPost: updatedComments);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Add comment to a post
  Future<bool> addComment({
    required int postId,
    required String content,
    int? parentCommentId,
  }) async {
    try {
      final result = await _postRepository.addComment(
        postId: postId,
        content: content,
        parentCommentId: parentCommentId,
      );

      if (result['success'] == true) {
        // Reload comments for this post
        await loadComments(postId);

        // Update comment count in feed
        final updatedFeed = state.feedPosts.map((post) {
          if (post.id == postId) {
            return post.copyWith(commentCount: post.commentCount + 1);
          }
          return post;
        }).toList();

        state = state.copyWith(feedPosts: updatedFeed);

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Delete comment
  Future<bool> deleteComment(int postId, int commentId) async {
    try {
      final success = await _postRepository.deleteComment(postId, commentId);

      if (success) {
        // Reload comments
        await loadComments(postId);

        // Update comment count
        final updatedFeed = state.feedPosts.map((post) {
          if (post.id == postId) {
            return post.copyWith(commentCount: post.commentCount - 1);
          }
          return post;
        }).toList();

        state = state.copyWith(feedPosts: updatedFeed);
      }

      return success;
    } catch (e) {
      return false;
    }
  }
}

// Post Provider
final postProvider = StateNotifierProvider<PostNotifier, PostState>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  return PostNotifier(postRepository);
});
