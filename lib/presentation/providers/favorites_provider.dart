import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/favorites_service.dart';
import '../../data/models/component.dart';
import '../../data/models/build.dart';

// Favorites Service Provider
final favoritesServiceProvider = Provider<FavoritesService>((ref) {
  return FavoritesService();
});

// Favorites State
class FavoritesState {
  final List<Component> favoriteComponents;
  final List<Build> favoriteBuilds;
  final bool isLoading;
  final String? error;

  FavoritesState({
    this.favoriteComponents = const [],
    this.favoriteBuilds = const [],
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    List<Component>? favoriteComponents,
    List<Build>? favoriteBuilds,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      favoriteComponents: favoriteComponents ?? this.favoriteComponents,
      favoriteBuilds: favoriteBuilds ?? this.favoriteBuilds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get totalFavorites => favoriteComponents.length + favoriteBuilds.length;

  bool get hasComponentFavorites => favoriteComponents.isNotEmpty;

  bool get hasBuildFavorites => favoriteBuilds.isNotEmpty;
}

// Favorites Notifier
class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoritesService _favoritesService;

  FavoritesNotifier(this._favoritesService) : super(FavoritesState()) {
    _initialize();
  }

  /// Initialize the favorites service and load favorites
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      await _favoritesService.init();
      await loadFavorites();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to initialize favorites: $e',
        isLoading: false,
      );
    }
  }

  /// Load all favorites from storage
  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final components = await _favoritesService.getAllFavoriteComponents();
      final builds = await _favoritesService.getAllFavoriteBuilds();

      state = state.copyWith(
        favoriteComponents: components,
        favoriteBuilds: builds,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load favorites: $e',
        isLoading: false,
      );
    }
  }

  /// Add component to favorites
  Future<bool> addComponentToFavorites(Component component) async {
    try {
      final success = await _favoritesService.addComponentToFavorites(component);

      if (success) {
        final updatedComponents = [...state.favoriteComponents, component];
        updatedComponents.sort((a, b) => a.name.compareTo(b.name));

        state = state.copyWith(favoriteComponents: updatedComponents);
        return true;
      }

      return false;
    } catch (e) {
      state = state.copyWith(error: 'Failed to add component to favorites: $e');
      return false;
    }
  }

  /// Remove component from favorites
  Future<bool> removeComponentFromFavorites(int componentId) async {
    try {
      final success = await _favoritesService.removeComponentFromFavorites(componentId);

      if (success) {
        final updatedComponents = state.favoriteComponents
            .where((c) => c.id != componentId)
            .toList();

        state = state.copyWith(favoriteComponents: updatedComponents);
        return true;
      }

      return false;
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove component from favorites: $e');
      return false;
    }
  }

  /// Toggle component favorite status
  Future<bool> toggleComponentFavorite(Component component) async {
    final isFavorited = await isComponentFavorited(component.id);

    if (isFavorited) {
      return await removeComponentFromFavorites(component.id);
    } else {
      return await addComponentToFavorites(component);
    }
  }

  /// Check if component is favorited
  Future<bool> isComponentFavorited(int componentId) async {
    return await _favoritesService.isComponentFavorited(componentId);
  }

  /// Add build to favorites
  Future<bool> addBuildToFavorites(Build build) async {
    try {
      final success = await _favoritesService.addBuildToFavorites(build);

      if (success) {
        final updatedBuilds = [...state.favoriteBuilds, build];
        updatedBuilds.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        state = state.copyWith(favoriteBuilds: updatedBuilds);
        return true;
      }

      return false;
    } catch (e) {
      state = state.copyWith(error: 'Failed to add build to favorites: $e');
      return false;
    }
  }

  /// Remove build from favorites
  Future<bool> removeBuildFromFavorites(String buildKey) async {
    try {
      final success = await _favoritesService.removeBuildFromFavorites(buildKey);

      if (success) {
        final updatedBuilds = state.favoriteBuilds
            .where((b) {
              final key = b.uuid ?? b.id?.toString() ?? '';
              return key != buildKey;
            })
            .toList();

        state = state.copyWith(favoriteBuilds: updatedBuilds);
        return true;
      }

      return false;
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove build from favorites: $e');
      return false;
    }
  }

  /// Toggle build favorite status
  Future<bool> toggleBuildFavorite(Build build) async {
    final buildKey = build.uuid ?? build.id?.toString() ?? '';
    final isFavorited = await isBuildFavorited(buildKey);

    if (isFavorited) {
      return await removeBuildFromFavorites(buildKey);
    } else {
      return await addBuildToFavorites(build);
    }
  }

  /// Check if build is favorited
  Future<bool> isBuildFavorited(String buildKey) async {
    return await _favoritesService.isBuildFavorited(buildKey);
  }

  /// Get favorites count
  Future<Map<String, int>> getFavoritesCount() async {
    return await _favoritesService.getFavoritesCount();
  }

  /// Clear all component favorites
  Future<bool> clearComponentFavorites() async {
    try {
      final success = await _favoritesService.clearComponentFavorites();

      if (success) {
        state = state.copyWith(favoriteComponents: []);
        return true;
      }

      return false;
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear component favorites: $e');
      return false;
    }
  }

  /// Clear all build favorites
  Future<bool> clearBuildFavorites() async {
    try {
      final success = await _favoritesService.clearBuildFavorites();

      if (success) {
        state = state.copyWith(favoriteBuilds: []);
        return true;
      }

      return false;
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear build favorites: $e');
      return false;
    }
  }

  /// Clear all favorites
  Future<bool> clearAllFavorites() async {
    try {
      final success = await _favoritesService.clearAllFavorites();

      if (success) {
        state = state.copyWith(
          favoriteComponents: [],
          favoriteBuilds: [],
        );
        return true;
      }

      return false;
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear all favorites: $e');
      return false;
    }
  }

  /// Refresh favorites
  Future<void> refresh() async {
    await loadFavorites();
  }
}

// Favorites Provider
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  final favoritesService = ref.watch(favoritesServiceProvider);
  return FavoritesNotifier(favoritesService);
});

// Individual component favorite status provider
final componentFavoriteStatusProvider = FutureProvider.family<bool, int>((ref, componentId) async {
  final favoritesService = ref.watch(favoritesServiceProvider);
  await favoritesService.init();
  return await favoritesService.isComponentFavorited(componentId);
});

// Individual build favorite status provider
final buildFavoriteStatusProvider = FutureProvider.family<bool, String>((ref, buildKey) async {
  final favoritesService = ref.watch(favoritesServiceProvider);
  await favoritesService.init();
  return await favoritesService.isBuildFavorited(buildKey);
});
