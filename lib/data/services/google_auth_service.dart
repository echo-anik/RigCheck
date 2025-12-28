import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/network/api_client.dart';
import '../../data/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Google OAuth Service for social authentication
class GoogleAuthService {
  final ApiClient _apiClient;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  GoogleAuthService(this._apiClient);

  /// Sign in with Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return {
          'success': false,
          'message': 'Sign-in cancelled by user',
        };
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        return {
          'success': false,
          'message': 'Failed to obtain Google credentials',
        };
      }

      // Send tokens to backend
      final response = await _apiClient.post(
        '/auth/google/callback',
        data: {
          'access_token': accessToken,
          'id_token': idToken,
          'email': googleUser.email,
          'name': googleUser.displayName,
          'avatar_url': googleUser.photoUrl,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // Extract token and user data
        String? token;
        Map<String, dynamic>? userData;
        
        if (data['data'] != null) {
          token = data['data']['token'] as String?;
          userData = data['data']['user'] as Map<String, dynamic>?;
        } else {
          token = data['token'] as String?;
          userData = data['user'] as Map<String, dynamic>?;
        }

        if (token != null && userData != null) {
          final user = User.fromJson(userData);

          // Save token
          await _saveAuthToken(token);
          await _saveUserId(user.id);

          return {
            'success': true,
            'user': user,
            'token': token,
            'message': 'Successfully signed in with Google',
          };
        }
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Google sign-in failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Silent fail
    }
  }

  /// Check if currently signed in with Google
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Get current Google user
  Future<GoogleSignInAccount?> getCurrentUser() async {
    return _googleSignIn.currentUser;
  }

  /// Silent sign-in (if previously signed in)
  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }
}
