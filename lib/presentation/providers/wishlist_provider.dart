import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/wishlist_service.dart';
import '../../data/models/wishlist_item.dart';
import '../../data/models/component.dart';
import '../../data/models/build.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../../data/repositories/component_repository.dart';
import '../../data/repositories/build_repository.dart';
import 'component_provider.dart';
import 'build_provider.dart';

// Wishlist Repository Provider
final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepository();
});

// Wishlist Service Provider
final wishlistServiceProvider = Provider<WishlistService>((ref) {
  final wishlistRepository = ref.watch(wishlistRepositoryProvider);
  final componentRepository = ref.watch(componentRepositoryProvider);
  final buildRepository = ref.watch(buildRepositoryProvider);

  return WishlistService(
    wishlistRepository: wishlistRepository,
    componentRepository: componentRepository,
    buildRepository: buildRepository,
  );
});

// Wishlist State
class WishlistState {
  final List<WishlistItem> items;
  final List<Component> components;
  final List<Build> builds;
  final bool isLoading;
  final String? error;
  final bool isInitialized;
  final double totalValue;

  WishlistState({
    this.items = const [],
    this.components = const [],
    this.builds = const [],
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
    this.totalValue = 0.0,
  });

  WishlistState copyWith({
    List<WishlistItem>? items,
    List<Component>? components,
    List<Build>? builds,
    bool? isLoading,
    String? error,
    bool? isInitialized,
    double? totalValue,
  }) {
    return WishlistState(
      items: items ?? this.items,
      components: components ?? this.components,
      builds: builds ?? this.builds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
      totalValue: totalValue ?? this.totalValue,
    );
  }

  int get itemCount => items.length;
  int get componentCount => components.length;
  int get buildCount => builds.length;
}

// Wishlist State Notifier
class WishlistNotifier extends StateNotifier<WishlistState> {
  final WishlistService _wishlistService;

  WishlistNotifier(this._wishlistService) : super(WishlistState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (state.isInitialized) return;

    state = state.copyWith(isLoading: true);

    try {
      await _wishlistService.init();
      await loadWishlist();

      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Load all wishlist items
  Future<void> loadWishlist() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get all wishlist items
      final items = await _wishlistService.getAllItems();

      // Get full component and build data
      final components = await _wishlistService.getWishlistComponents();
      final builds = await _wishlistService.getWishlistBuilds();

      // Calculate total value
      final totalValue = await _wishlistService.getTotalValue();

      state = state.copyWith(
        items: items,
        components: components,
        builds: builds,
        totalValue: totalValue,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Add a component to the wishlist
  Future<bool> addComponent(String componentId) async {
    try {
      final result = await _wishlistService.addComponent(componentId);

      if (result) {
        await loadWishlist();
      }

      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Add a build to the wishlist
  Future<bool> addBuild(String buildId) async {
    try {
      final result = await _wishlistService.addBuild(buildId);

      if (result) {
        await loadWishlist();
      }

      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Remove a component from the wishlist
  Future<bool> removeComponent(String componentId) async {
    try {
      final result = await _wishlistService.removeComponent(componentId);

      if (result) {
        await loadWishlist();
      }

      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Remove a build from the wishlist
  Future<bool> removeBuild(String buildId) async {
    try {
      final result = await _wishlistService.removeBuild(buildId);

      if (result) {
        await loadWishlist();
      }

      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Toggle a component in the wishlist
  Future<bool> toggleComponent(String componentId) async {
    try {
      final result = await _wishlistService.toggleComponent(componentId);

      if (result) {
        await loadWishlist();
      }

      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Toggle a build in the wishlist
  Future<bool> toggleBuild(String buildId) async {
    try {
      final result = await _wishlistService.toggleBuild(buildId);

      if (result) {
        await loadWishlist();
      }

      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Check if a component is in the wishlist
  Future<bool> isComponentInWishlist(String componentId) async {
    try {
      return await _wishlistService.isComponentInWishlist(componentId);
    } catch (e) {
      return false;
    }
  }

  /// Check if a build is in the wishlist
  Future<bool> isBuildInWishlist(String buildId) async {
    try {
      return await _wishlistService.isBuildInWishlist(buildId);
    } catch (e) {
      return false;
    }
  }

  /// Clear the entire wishlist
  Future<bool> clearWishlist() async {
    try {
      final result = await _wishlistService.clearWishlist();

      if (result) {
        state = WishlistState(isInitialized: true);
      }

      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Refresh wishlist data
  Future<void> refresh() async {
    await loadWishlist();
  }
}

// Wishlist Provider
final wishlistProvider = StateNotifierProvider<WishlistNotifier, WishlistState>((ref) {
  final wishlistService = ref.watch(wishlistServiceProvider);
  return WishlistNotifier(wishlistService);
});

// Helper provider to check if a component is in wishlist
final isComponentInWishlistProvider = FutureProvider.family<bool, String>((ref, componentId) async {
  final wishlistNotifier = ref.watch(wishlistProvider.notifier);
  return await wishlistNotifier.isComponentInWishlist(componentId);
});

// Helper provider to check if a build is in wishlist
final isBuildInWishlistProvider = FutureProvider.family<bool, String>((ref, buildId) async {
  final wishlistNotifier = ref.watch(wishlistProvider.notifier);
  return await wishlistNotifier.isBuildInWishlist(buildId);
});

// Wishlist count provider
final wishlistCountProvider = Provider<int>((ref) {
  final wishlistState = ref.watch(wishlistProvider);
  return wishlistState.itemCount;
});
