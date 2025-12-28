import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/repositories/build_repository.dart';
import '../../core/services/sync_queue_service.dart';
import 'build_provider.dart';

/// State for build likes
class BuildLikesState {
  final Set<int> likedBuildIds;
  final Map<int, int> likeCounts; // buildId -> count
  final bool isLoading;
  final String? error;

  BuildLikesState({
    this.likedBuildIds = const {},
    this.likeCounts = const {},
    this.isLoading = false,
    this.error,
  });

  BuildLikesState copyWith({
    Set<int>? likedBuildIds,
    Map<int, int>? likeCounts,
    bool? isLoading,
    String? error,
  }) {
    return BuildLikesState(
      likedBuildIds: likedBuildIds ?? this.likedBuildIds,
      likeCounts: likeCounts ?? this.likeCounts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing build likes
class BuildLikesNotifier extends StateNotifier<BuildLikesState> {
  static const String _likedBuildsKey = 'liked_builds';
  static const String _likeCountsKey = 'like_counts';

  final BuildRepository _buildRepository;
  final SyncQueueService _syncQueueService;

  BuildLikesNotifier(
    this._buildRepository,
    this._syncQueueService,
  ) : super(BuildLikesState()) {
    _loadLikedBuilds();
  }

  /// Load liked builds from local storage
  Future<void> _loadLikedBuilds() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final likedBuildsJson = prefs.getStringList(_likedBuildsKey) ?? [];
      final likedBuildIds = likedBuildsJson
          .map((id) => int.tryParse(id))
          .whereType<int>()
          .toSet();

      final likeCountsJson = prefs.getString(_likeCountsKey);
      Map<int, int> likeCounts = {};
      if (likeCountsJson != null) {
        // Parse JSON string to map
        // This is a simple implementation, you might want to use json_serializable
      }

      state = state.copyWith(
        likedBuildIds: likedBuildIds,
        likeCounts: likeCounts,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Save liked builds to local storage
  Future<void> _saveLikedBuilds() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final likedBuildsJson = state.likedBuildIds
          .map((id) => id.toString())
          .toList();

      await prefs.setStringList(_likedBuildsKey, likedBuildsJson);
    } catch (e) {
      // Log error but don't fail the operation
    }
  }

  /// Toggle like status for a build
  Future<void> toggleBuildLike(int buildId) async {
    final isCurrentlyLiked = state.likedBuildIds.contains(buildId);
    final newLikeCount = (state.likeCounts[buildId] ?? 0) + (isCurrentlyLiked ? -1 : 1);

    // Optimistic update
    final newLikedBuildIds = Set<int>.from(state.likedBuildIds);
    final newLikeCounts = Map<int, int>.from(state.likeCounts);

    if (isCurrentlyLiked) {
      newLikedBuildIds.remove(buildId);
    } else {
      newLikedBuildIds.add(buildId);
    }
    newLikeCounts[buildId] = newLikeCount;

    state = state.copyWith(
      likedBuildIds: newLikedBuildIds,
      likeCounts: newLikeCounts,
    );

    // Save to local storage immediately
    await _saveLikedBuilds();

    // Try to sync with API
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      if (!connectivityResult.contains(ConnectivityResult.none)) {
        // Online - call API directly
        final result = isCurrentlyLiked
            ? await _buildRepository.unlikeBuild(buildId)
            : await _buildRepository.likeBuild(buildId);

        if (result['success'] == true) {
          // Update like count from server
          final serverLikeCount = result['like_count'] as int;
          final updatedLikeCounts = Map<int, int>.from(state.likeCounts);
          updatedLikeCounts[buildId] = serverLikeCount;

          state = state.copyWith(likeCounts: updatedLikeCounts);
        } else {
          // API call failed, revert optimistic update
          _revertLikeToggle(buildId, isCurrentlyLiked);
        }
      } else {
        // Offline - queue action for later sync
        await _syncQueueService.queueAction(
          type: isCurrentlyLiked ? 'unlike' : 'like',
          endpoint: '/builds/$buildId/like',
        );
      }
    } catch (e) {
      // Error - revert optimistic update and queue for sync
      _revertLikeToggle(buildId, isCurrentlyLiked);

      await _syncQueueService.queueAction(
        type: isCurrentlyLiked ? 'unlike' : 'like',
        endpoint: '/builds/$buildId/like',
      );
    }
  }

  /// Revert optimistic update if API call fails
  void _revertLikeToggle(int buildId, bool wasLiked) {
    final newLikedBuildIds = Set<int>.from(state.likedBuildIds);
    final newLikeCounts = Map<int, int>.from(state.likeCounts);

    if (wasLiked) {
      newLikedBuildIds.add(buildId);
      newLikeCounts[buildId] = (newLikeCounts[buildId] ?? 0) + 1;
    } else {
      newLikedBuildIds.remove(buildId);
      newLikeCounts[buildId] = (newLikeCounts[buildId] ?? 1) - 1;
    }

    state = state.copyWith(
      likedBuildIds: newLikedBuildIds,
      likeCounts: newLikeCounts,
    );

    _saveLikedBuilds();
  }

  /// Check if a build is liked
  bool isBuildLiked(int buildId) {
    return state.likedBuildIds.contains(buildId);
  }

  /// Get like count for a build
  int getLikeCount(int buildId) {
    return state.likeCounts[buildId] ?? 0;
  }

  /// Sync likes with server
  Future<void> syncLikes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // This would typically be called after processing the sync queue
      // The actual sync logic is handled by the sync queue service

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear all likes (for logout, etc.)
  Future<void> clearLikes() async {
    state = BuildLikesState();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_likedBuildsKey);
    await prefs.remove(_likeCountsKey);
  }
}

/// Provider for sync queue service
final syncQueueServiceProvider = Provider<SyncQueueService>((ref) {
  final service = SyncQueueService();
  service.init();
  return service;
});

/// Provider for build likes state
final buildLikesProvider =
    StateNotifierProvider<BuildLikesNotifier, BuildLikesState>((ref) {
  final buildRepository = ref.watch(buildRepositoryProvider);
  final syncQueueService = ref.watch(syncQueueServiceProvider);
  return BuildLikesNotifier(buildRepository, syncQueueService);
});

/// Family provider to check if a specific build is liked
final isBuildLikedProvider = Provider.family<bool, int>((ref, buildId) {
  final likesState = ref.watch(buildLikesProvider);
  return likesState.likedBuildIds.contains(buildId);
});

/// Family provider to get like count for a specific build
final buildLikeCountProvider = Provider.family<int, int>((ref, buildId) {
  final likesState = ref.watch(buildLikesProvider);
  return likesState.likeCounts[buildId] ?? 0;
});
