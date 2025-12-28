import '../../core/network/api_client.dart';
import '../models/user.dart';

class SocialRepository {
  final ApiClient _apiClient;

  SocialRepository(this._apiClient);

  /// Follow a user
  Future<Map<String, dynamic>> followUser(int userId) async {
    try {
      final response = await _apiClient.post('/users/$userId/follow');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'is_following': true,
        };
      }

      return {
        'success': false,
        'message': 'Failed to follow user',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Unfollow a user
  Future<Map<String, dynamic>> unfollowUser(int userId) async {
    try {
      final response = await _apiClient.delete('/users/$userId/follow');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'is_following': false,
        };
      }

      return {
        'success': false,
        'message': 'Failed to unfollow user',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Get user's followers
  Future<List<User>> getFollowers(int userId, {int page = 1, int perPage = 20}) async {
    try {
      final response = await _apiClient.get(
        '/users/$userId/followers',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load followers: $e');
    }
  }

  /// Get users that this user is following
  Future<List<User>> getFollowing(int userId, {int page = 1, int perPage = 20}) async {
    try {
      final response = await _apiClient.get(
        '/users/$userId/following',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load following: $e');
    }
  }

  /// Check if current user is following another user
  Future<bool> isFollowing(int userId) async {
    try {
      final response = await _apiClient.get('/users/$userId/follow/status');

      if (response.statusCode == 200) {
        return response.data['data']['is_following'] as bool? ?? false;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get follower/following counts for a user
  Future<Map<String, int>> getFollowCounts(int userId) async {
    try {
      final response = await _apiClient.get('/users/$userId/follow/counts');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return {
          'followers': data['followers_count'] as int? ?? 0,
          'following': data['following_count'] as int? ?? 0,
        };
      }

      return {'followers': 0, 'following': 0};
    } catch (e) {
      return {'followers': 0, 'following': 0};
    }
  }
}
