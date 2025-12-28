import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/user.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle different API response formats
        String? token;
        Map<String, dynamic>? userData;
        
        // Format 1: data.token and data.user
        if (data['data'] != null) {
          token = data['data']['token'] as String?;
          userData = data['data']['user'] as Map<String, dynamic>?;
        }
        // Format 2: token and user at root level
        else if (data['token'] != null) {
          token = data['token'] as String?;
          userData = data['user'] as Map<String, dynamic>?;
        }
        
        if (token != null && userData != null) {
          final user = User.fromJson(userData);

          // Save token to shared preferences
          await _saveAuthToken(token);
          await _saveUserId(user.id);

          return {
            'success': true,
            'user': user,
            'token': token,
          };
        }
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Login failed',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error. Please try again.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    {String? displayName}
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {
          'name': username,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        
        // Handle different API response formats
        String? token;
        Map<String, dynamic>? userData;
        
        // Format 1: data.token and data.user
        if (data['data'] != null) {
          token = data['data']['token'] as String?;
          userData = data['data']['user'] as Map<String, dynamic>?;
        }
        // Format 2: token and user at root level
        else if (data['token'] != null) {
          token = data['token'] as String?;
          userData = data['user'] as Map<String, dynamic>?;
        }
        
        if (token != null && userData != null) {
          final user = User.fromJson(userData);

          // Save token to shared preferences
          await _saveAuthToken(token);
          await _saveUserId(user.id);

          return {
            'success': true,
            'user': user,
            'token': token,
          };
        }
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Registration failed',
      };
    } on DioException catch (e) {
      // Handle validation errors
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          final firstError = errors.values.first;
          final errorMessage = firstError is List ? firstError.first : firstError;
          return {
            'success': false,
            'message': errorMessage.toString(),
          };
        }
      }
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error. Please try again.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (e) {
      // Continue logout even if API call fails
    } finally {
      await _clearAuthData();
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      final response = await _apiClient.get(ApiConstants.user);

      if (response.statusCode == 200) {
        final userData = response.data['data'] as Map<String, dynamic>;
        return User.fromJson(userData);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _getAuthToken();
    return token != null;
  }

  Future<void> _saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? displayName,
    String? bio,
    String? locationCity,
  }) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.userProfile,
        data: {
          if (displayName != null) 'display_name': displayName,
          if (bio != null) 'bio': bio,
          if (locationCity != null) 'location_city': locationCity,
        },
      );

      if (response.statusCode == 200) {
        final userData = response.data['data'] as Map<String, dynamic>;
        final user = User.fromJson(userData);

        return {
          'success': true,
          'user': user,
        };
      }

      return {
        'success': false,
        'message': 'Failed to update profile',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Upload user avatar
  Future<Map<String, dynamic>> uploadAvatar(dynamic imageFile) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'avatar.jpg',
        ),
      });

      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}/upload/avatar',
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final avatarUrl = response.data['data']['avatar_url'] as String;

        return {
          'success': true,
          'avatar_url': avatarUrl,
          'message': 'Avatar uploaded successfully',
        };
      }

      return {
        'success': false,
        'message': 'Failed to upload avatar',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password changed successfully',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to change password',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Delete user account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await _apiClient.delete(ApiConstants.deleteAccount);

      if (response.statusCode == 200 || response.statusCode == 204) {
        await _clearAuthData();

        return {
          'success': true,
          'message': 'Account deleted successfully',
        };
      }

      return {
        'success': false,
        'message': 'Failed to delete account',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Get user preferences
  Future<Map<String, dynamic>?> getUserPreferences() async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      final response = await _apiClient.get(ApiConstants.userPreferences);

      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update user preferences
  Future<Map<String, dynamic>> updateUserPreferences(
      Map<String, dynamic> preferences) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.userPreferences,
        data: preferences,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Preferences updated successfully',
        };
      }

      return {
        'success': false,
        'message': 'Failed to update preferences',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
