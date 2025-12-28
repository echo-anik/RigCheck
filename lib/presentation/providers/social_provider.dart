import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user.dart';
import '../../data/repositories/social_repository.dart';
import 'auth_provider.dart';

// Social Repository Provider
final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SocialRepository(apiClient);
});

// Social State
class SocialState {
  final Map<int, bool> followStatus; // userId -> isFollowing
  final Map<int, Map<String, int>> followCounts; // userId -> {followers, following}
  final List<User> followers;
  final List<User> following;
  final bool isLoading;
  final String? error;

  SocialState({
    this.followStatus = const {},
    this.followCounts = const {},
    this.followers = const [],
    this.following = const [],
    this.isLoading = false,
    this.error,
  });

  SocialState copyWith({
    Map<int, bool>? followStatus,
    Map<int, Map<String, int>>? followCounts,
    List<User>? followers,
    List<User>? following,
    bool? isLoading,
    String? error,
  }) {
    return SocialState(
      followStatus: followStatus ?? this.followStatus,
      followCounts: followCounts ?? this.followCounts,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Social State Notifier
class SocialNotifier extends StateNotifier<SocialState> {
  final SocialRepository _socialRepository;

  SocialNotifier(this._socialRepository) : super(SocialState());

  /// Toggle follow status for a user
  Future<bool> toggleFollow(int userId) async {
    final currentStatus = state.followStatus[userId] ?? false;

    try {
      final result = currentStatus
          ? await _socialRepository.unfollowUser(userId)
          : await _socialRepository.followUser(userId);

      if (result['success'] == true) {
        final newStatus = result['is_following'] as bool;

        // Update follow status
        final updatedStatus = Map<int, bool>.from(state.followStatus);
        updatedStatus[userId] = newStatus;

        // Update follow counts if available
        final updatedCounts = Map<int, Map<String, int>>.from(state.followCounts);
        if (updatedCounts.containsKey(userId)) {
          final counts = updatedCounts[userId]!;
          updatedCounts[userId] = {
            'followers': counts['followers']! + (newStatus ? 1 : -1),
            'following': counts['following']!,
          };
        }

        state = state.copyWith(
          followStatus: updatedStatus,
          followCounts: updatedCounts,
        );

        return true;
      }

      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Load follow status for a user
  Future<void> loadFollowStatus(int userId) async {
    try {
      final isFollowing = await _socialRepository.isFollowing(userId);

      final updatedStatus = Map<int, bool>.from(state.followStatus);
      updatedStatus[userId] = isFollowing;

      state = state.copyWith(followStatus: updatedStatus);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load follow counts for a user
  Future<void> loadFollowCounts(int userId) async {
    try {
      final counts = await _socialRepository.getFollowCounts(userId);

      final updatedCounts = Map<int, Map<String, int>>.from(state.followCounts);
      updatedCounts[userId] = counts;

      state = state.copyWith(followCounts: updatedCounts);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load followers for a user
  Future<void> loadFollowers(int userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final followers = await _socialRepository.getFollowers(userId);

      state = state.copyWith(
        followers: followers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Load following for a user
  Future<void> loadFollowing(int userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final following = await _socialRepository.getFollowing(userId);

      state = state.copyWith(
        following: following,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}

// Social Provider
final socialProvider = StateNotifierProvider<SocialNotifier, SocialState>((ref) {
  final socialRepository = ref.watch(socialRepositoryProvider);
  return SocialNotifier(socialRepository);
});

// Helper provider to check if following a specific user
final isFollowingProvider = Provider.family<bool, int>((ref, userId) {
  final socialState = ref.watch(socialProvider);
  return socialState.followStatus[userId] ?? false;
});

// Helper provider to get follow counts for a specific user
final followCountsProvider = Provider.family<Map<String, int>, int>((ref, userId) {
  final socialState = ref.watch(socialProvider);
  return socialState.followCounts[userId] ?? {'followers': 0, 'following': 0};
});
