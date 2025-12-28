import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/google_auth_service.dart';
import '../../core/network/api_client.dart';
import '../../data/models/user.dart';

/// Provider for GoogleAuthService
final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService(ApiClient());
});

/// Google Sign-In State
class GoogleSignInState {
  final bool isLoading;
  final bool isSignedIn;
  final User? user;
  final String? error;

  GoogleSignInState({
    this.isLoading = false,
    this.isSignedIn = false,
    this.user,
    this.error,
  });

  GoogleSignInState copyWith({
    bool? isLoading,
    bool? isSignedIn,
    User? user,
    String? error,
  }) {
    return GoogleSignInState(
      isLoading: isLoading ?? this.isLoading,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// Google Sign-In Notifier
class GoogleSignInNotifier extends StateNotifier<GoogleSignInState> {
  final GoogleAuthService _authService;

  GoogleSignInNotifier(this._authService) : super(GoogleSignInState());

  /// Sign in with Google
  Future<Map<String, dynamic>> signIn() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.signInWithGoogle();

    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        isSignedIn: true,
        user: result['user'] as User,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        isSignedIn: false,
        error: result['message'] as String,
      );
    }
    
    return result;
  }

  /// Sign out from Google
  Future<void> signOut() async {
    await _authService.signOut();
    state = GoogleSignInState();
  }

  /// Check if signed in
  Future<void> checkSignInStatus() async {
    final isSignedIn = await _authService.isSignedIn();
    if (isSignedIn) {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        state = state.copyWith(isSignedIn: true);
      }
    }
  }

  /// Silent sign-in
  Future<void> signInSilently() async {
    final user = await _authService.signInSilently();
    if (user != null) {
      state = state.copyWith(isSignedIn: true);
    }
  }
}

final googleSignInProvider =
    StateNotifierProvider<GoogleSignInNotifier, GoogleSignInState>((ref) {
  final authService = ref.watch(googleAuthServiceProvider);
  return GoogleSignInNotifier(authService);
});
