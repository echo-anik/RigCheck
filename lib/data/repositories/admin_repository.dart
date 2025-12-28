import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/admin_stats.dart';

class AdminRepository {
  final ApiClient _apiClient;

  AdminRepository(this._apiClient);

  Future<AdminStats> getAdminStats() async {
    try {
      final response = await _apiClient.get(ApiConstants.adminStats);
      
      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return AdminStats.fromJson(data);
      } else {
        throw Exception('Failed to fetch admin stats: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('Access denied: Admin privileges required');
      }
      throw Exception('Failed to fetch admin stats: $e');
    }
  }

  Future<Map<String, dynamic>> getUsersList({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.adminUsers,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('Access denied: Admin privileges required');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<void> updateUser(int userId, Map<String, dynamic> updates) async {
    try {
      final response = await _apiClient.put(ApiConstants.adminUserById(userId), data: updates);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('Access denied: Admin privileges required');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      final response = await _apiClient.delete(ApiConstants.adminUserById(userId));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('Access denied: Admin privileges required');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.post(ApiConstants.adminUsers, data: userData);

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to create user: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('Access denied: Admin privileges required');
      }
      throw Exception('Network error: $e');
    }
  }

  // Component Management Methods

  Future<Map<String, dynamic>> getComponentsList({
    int page = 1,
    int perPage = 20,
    String? category,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.adminComponents,
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (category != null) 'category': category,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch components: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('Access denied: Admin privileges required');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<void> createComponent(Map<String, dynamic> componentData) async {
    try {
      final response = await _apiClient.post(ApiConstants.adminComponents, data: componentData);

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to create component: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('Access denied: Admin privileges required');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<void> updateComponent(int componentId, Map<String, dynamic> updates) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.adminComponentById(componentId),
        data: updates,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update component: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('Access denied: Admin privileges required');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteComponent(int componentId) async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.adminComponentById(componentId),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete component: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('Access denied: Admin privileges required');
      }
      throw Exception('Network error: $e');
    }
  }

  // Build Management Methods (for future use)

  Future<Map<String, dynamic>> getBuildsList({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.adminBuilds,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch builds: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('Access denied: Admin privileges required');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteBuild(int buildId) async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.adminBuildById(buildId),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete build: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('Access denied: Admin privileges required');
      }
      throw Exception('Network error: $e');
    }
  }
}
