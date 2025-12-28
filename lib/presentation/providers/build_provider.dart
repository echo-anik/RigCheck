import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/build.dart';
import '../../data/repositories/build_repository.dart';
import 'auth_provider.dart';

// Build Repository Provider
final buildRepositoryProvider = Provider<BuildRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BuildRepository(apiClient);
});

// FutureProvider for loading user's builds (auto-loads when watched)
final myBuildsListProvider = FutureProvider<List<Build>>((ref) async {
  final repository = ref.watch(buildRepositoryProvider);
  return await repository.getMyBuilds();
});

// Build State
class BuildState {
  final List<Build> myBuilds;
  final List<Build> publicBuilds;
  final Build? currentBuild;
  final bool isLoading;
  final String? error;

  BuildState({
    this.myBuilds = const [],
    this.publicBuilds = const [],
    this.currentBuild,
    this.isLoading = false,
    this.error,
  });

  BuildState copyWith({
    List<Build>? myBuilds,
    List<Build>? publicBuilds,
    Build? currentBuild,
    bool? isLoading,
    String? error,
  }) {
    return BuildState(
      myBuilds: myBuilds ?? this.myBuilds,
      publicBuilds: publicBuilds ?? this.publicBuilds,
      currentBuild: currentBuild ?? this.currentBuild,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Build State Notifier
class BuildNotifier extends StateNotifier<BuildState> {
  final BuildRepository _buildRepository;

  BuildNotifier(this._buildRepository) : super(BuildState());

  /// Load user's builds
  Future<void> loadMyBuilds({int? page, int? perPage}) async {
    if (mounted) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final builds = await _buildRepository.getMyBuilds(
        page: page,
        perPage: perPage,
      );

      if (mounted) {
        state = state.copyWith(
          myBuilds: builds,
          isLoading: false,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          error: e.toString(),
          isLoading: false,
        );
      }
    }
  }

  /// Load public builds (community feed)
  Future<void> loadPublicBuilds({
    String? compatibilityStatus,
    String? search,
    double? minCost,
    double? maxCost,
    String? sortBy,
    String? sortOrder,
    int? page,
    int? perPage,
  }) async {
    if (mounted) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final builds = await _buildRepository.getPublicBuilds(
        compatibilityStatus: compatibilityStatus,
        search: search,
        minCost: minCost,
        maxCost: maxCost,
        sortBy: sortBy,
        sortOrder: sortOrder,
        page: page,
        perPage: perPage,
      );

      if (mounted) {
        state = state.copyWith(
          publicBuilds: builds,
          isLoading: false,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          error: e.toString(),
          isLoading: false,
        );
      }
    }
  }

  /// Load specific build by ID
  Future<void> loadBuild(int id) async {
    if (mounted) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final build = await _buildRepository.getBuildById(id);

      if (mounted) {
        state = state.copyWith(
          currentBuild: build,
          isLoading: false,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          error: e.toString(),
          isLoading: false,
        );
      }
    }
  }

  /// Create a new build (new API structure)
  Future<bool> createBuild({
    required String buildName,
    String? description,
    required String useCase,
    required double budgetMaxBdt,
    String visibility = 'public',
    required List<Map<String, dynamic>> components,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _buildRepository.createBuild(
        buildName: buildName,
        description: description,
        useCase: useCase,
        budgetMaxBdt: budgetMaxBdt,
        visibility: visibility,
        components: components,
      );

      if (result['success'] == true) {
        final newBuild = result['build'] as Build;

        // Add to my builds list
        state = state.copyWith(
          myBuilds: [newBuild, ...state.myBuilds],
          currentBuild: newBuild,
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

  /// Update an existing build (new API structure)
  Future<bool> updateBuild({
    required int id,
    String? buildName,
    String? description,
    String? useCase,
    double? budgetMaxBdt,
    String? visibility,
    List<Map<String, dynamic>>? components,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _buildRepository.updateBuild(
        id: id,
        buildName: buildName,
        description: description,
        useCase: useCase,
        budgetMaxBdt: budgetMaxBdt,
        visibility: visibility,
        components: components,
      );

      if (result['success'] == true) {
        final updatedBuild = result['build'] as Build;

        // Update in my builds list
        final updatedMyBuilds = state.myBuilds.map((build) {
          return build.id == id ? updatedBuild : build;
        }).toList();

        state = state.copyWith(
          myBuilds: updatedMyBuilds,
          currentBuild: updatedBuild,
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

  /// Delete a build
  Future<bool> deleteBuild(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _buildRepository.deleteBuild(id);

      if (success) {
        // Remove from my builds list
        final updatedMyBuilds = state.myBuilds
            .where((build) => build.id != id)
            .toList();

        state = state.copyWith(
          myBuilds: updatedMyBuilds,
          isLoading: false,
        );

        return true;
      } else {
        state = state.copyWith(
          error: 'Failed to delete build',
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

  /// Like a build
  Future<bool> likeBuild(int id) async {
    try {
      final result = await _buildRepository.likeBuild(id);

      if (result['success'] == true) {
        // Like count is tracked on the backend
        // The Build model doesn't currently store like count locally
        // Could be added as a future enhancement
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Clear current build
  void clearCurrentBuild() {
    state = state.copyWith(currentBuild: null);
  }
}

// Build Provider
final buildProvider = StateNotifierProvider<BuildNotifier, BuildState>((ref) {
  final buildRepository = ref.watch(buildRepositoryProvider);
  return BuildNotifier(buildRepository);
});
