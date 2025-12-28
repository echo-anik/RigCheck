import '../../core/network/api_client.dart';
import '../models/post.dart';
import '../models/comment.dart';

class PostRepository {
  final ApiClient _apiClient;

  PostRepository(this._apiClient);

  /// Get feed posts (all public posts or from followed users)
  Future<List<Post>> getFeedPosts({
    int page = 1,
    int perPage = 20,
    bool followedOnly = false,
  }) async {
    try {
      final response = await _apiClient.get(
        '/posts/feed',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (followedOnly) 'followed_only': true,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load feed: $e');
    }
  }

  /// Get posts by user ID
  Future<List<Post>> getUserPosts(int userId, {int page = 1, int perPage = 20}) async {
    try {
      final response = await _apiClient.get(
        '/users/$userId/posts',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load user posts: $e');
    }
  }

  /// Get single post by ID
  Future<Post?> getPostById(int id) async {
    try {
      final response = await _apiClient.get('/posts/$id');

      if (response.statusCode == 200) {
        return Post.fromJson(response.data['data'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to load post: $e');
    }
  }

  /// Create new post
  Future<Map<String, dynamic>> createPost({
    required String content,
    String? imageUrl,
    int? buildId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/posts',
        data: {
          'content': content,
          if (imageUrl != null) 'image_url': imageUrl,
          if (buildId != null) 'build_id': buildId,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'post': Post.fromJson(response.data['data'] as Map<String, dynamic>),
        };
      }

      return {
        'success': false,
        'message': 'Failed to create post',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Update post
  Future<Map<String, dynamic>> updatePost({
    required int id,
    required String content,
    String? imageUrl,
  }) async {
    try {
      final response = await _apiClient.put(
        '/posts/$id',
        data: {
          'content': content,
          if (imageUrl != null) 'image_url': imageUrl,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'post': Post.fromJson(response.data['data'] as Map<String, dynamic>),
        };
      }

      return {
        'success': false,
        'message': 'Failed to update post',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Delete post
  Future<bool> deletePost(int id) async {
    try {
      final response = await _apiClient.delete('/posts/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  /// Like/unlike post
  Future<Map<String, dynamic>> toggleLike(int postId) async {
    try {
      final response = await _apiClient.post('/posts/$postId/like');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return {
          'success': true,
          'liked': data['liked'] as bool,
          'like_count': data['like_count'] as int,
        };
      }

      return {'success': false};
    } catch (e) {
      return {'success': false};
    }
  }

  /// Get comments for a post
  Future<List<Comment>> getComments(int postId, {int page = 1, int perPage = 50}) async {
    try {
      final response = await _apiClient.get(
        '/posts/$postId/comments',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Comment.fromJson(json as Map<String, dynamic>)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load comments: $e');
    }
  }

  /// Add comment to post
  Future<Map<String, dynamic>> addComment({
    required int postId,
    required String content,
    int? parentCommentId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/posts/$postId/comments',
        data: {
          'content': content,
          if (parentCommentId != null) 'parent_comment_id': parentCommentId,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'comment': Comment.fromJson(response.data['data'] as Map<String, dynamic>),
        };
      }

      return {
        'success': false,
        'message': 'Failed to add comment',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Delete comment
  Future<bool> deleteComment(int postId, int commentId) async {
    try {
      final response = await _apiClient.delete('/posts/$postId/comments/$commentId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
