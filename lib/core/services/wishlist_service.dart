import 'package:logger/logger.dart';
import '../../data/models/wishlist_item.dart';
import '../../data/models/component.dart';
import '../../data/models/build.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../../data/repositories/component_repository.dart';
import '../../data/repositories/build_repository.dart';

/// Service for managing wishlist business logic
class WishlistService {
  final WishlistRepository _wishlistRepository;
  final ComponentRepository _componentRepository;
  final BuildRepository _buildRepository;
  final Logger _logger = Logger();

  WishlistService({
    required WishlistRepository wishlistRepository,
    required ComponentRepository componentRepository,
    required BuildRepository buildRepository,
  })  : _wishlistRepository = wishlistRepository,
        _componentRepository = componentRepository,
        _buildRepository = buildRepository;

  /// Initialize the service
  Future<void> init() async {
    await _wishlistRepository.init();
  }

  /// Add a component to the wishlist
  Future<bool> addComponent(String componentId) async {
    try {
      final item = WishlistItem(
        id: componentId,
        type: WishlistItemType.component,
      );

      final result = await _wishlistRepository.addItem(item);
      if (result) {
        _logger.i('Added component $componentId to wishlist');
      }
      return result;
    } catch (e) {
      _logger.e('Failed to add component to wishlist: $e');
      return false;
    }
  }

  /// Add a build to the wishlist
  Future<bool> addBuild(String buildId) async {
    try {
      final item = WishlistItem(
        id: buildId,
        type: WishlistItemType.build,
      );

      final result = await _wishlistRepository.addItem(item);
      if (result) {
        _logger.i('Added build $buildId to wishlist');
      }
      return result;
    } catch (e) {
      _logger.e('Failed to add build to wishlist: $e');
      return false;
    }
  }

  /// Remove a component from the wishlist
  Future<bool> removeComponent(String componentId) async {
    try {
      final result = await _wishlistRepository.removeItem(
        componentId,
        WishlistItemType.component,
      );
      if (result) {
        _logger.i('Removed component $componentId from wishlist');
      }
      return result;
    } catch (e) {
      _logger.e('Failed to remove component from wishlist: $e');
      return false;
    }
  }

  /// Remove a build from the wishlist
  Future<bool> removeBuild(String buildId) async {
    try {
      final result = await _wishlistRepository.removeItem(
        buildId,
        WishlistItemType.build,
      );
      if (result) {
        _logger.i('Removed build $buildId from wishlist');
      }
      return result;
    } catch (e) {
      _logger.e('Failed to remove build from wishlist: $e');
      return false;
    }
  }

  /// Toggle component in wishlist
  Future<bool> toggleComponent(String componentId) async {
    try {
      final isInWishlist = await _wishlistRepository.isInWishlist(
        componentId,
        WishlistItemType.component,
      );

      if (isInWishlist) {
        return await removeComponent(componentId);
      } else {
        return await addComponent(componentId);
      }
    } catch (e) {
      _logger.e('Failed to toggle component in wishlist: $e');
      return false;
    }
  }

  /// Toggle build in wishlist
  Future<bool> toggleBuild(String buildId) async {
    try {
      final isInWishlist = await _wishlistRepository.isInWishlist(
        buildId,
        WishlistItemType.build,
      );

      if (isInWishlist) {
        return await removeBuild(buildId);
      } else {
        return await addBuild(buildId);
      }
    } catch (e) {
      _logger.e('Failed to toggle build in wishlist: $e');
      return false;
    }
  }

  /// Check if a component is in the wishlist
  Future<bool> isComponentInWishlist(String componentId) async {
    try {
      return await _wishlistRepository.isInWishlist(
        componentId,
        WishlistItemType.component,
      );
    } catch (e) {
      _logger.e('Failed to check if component is in wishlist: $e');
      return false;
    }
  }

  /// Check if a build is in the wishlist
  Future<bool> isBuildInWishlist(String buildId) async {
    try {
      return await _wishlistRepository.isInWishlist(
        buildId,
        WishlistItemType.build,
      );
    } catch (e) {
      _logger.e('Failed to check if build is in wishlist: $e');
      return false;
    }
  }

  /// Get all wishlist items
  Future<List<WishlistItem>> getAllItems() async {
    try {
      return await _wishlistRepository.getAllItems();
    } catch (e) {
      _logger.e('Failed to get all wishlist items: $e');
      return [];
    }
  }

  /// Get all wishlist components with full data
  Future<List<Component>> getWishlistComponents() async {
    try {
      final items = await _wishlistRepository.getItemsByType(
        WishlistItemType.component,
      );

      final components = <Component>[];

      for (var item in items) {
        try {
          // Try to fetch component from API
          final component = await _componentRepository.getComponentById(item.id);
          if (component != null) {
            components.add(component);
          }
        } catch (e) {
          _logger.w('Failed to fetch component ${item.id}: $e');
        }
      }

      _logger.d('Retrieved ${components.length} wishlist components');
      return components;
    } catch (e) {
      _logger.e('Failed to get wishlist components: $e');
      return [];
    }
  }

  /// Get all wishlist builds with full data
  Future<List<Build>> getWishlistBuilds() async {
    try {
      final items = await _wishlistRepository.getItemsByType(
        WishlistItemType.build,
      );

      final builds = <Build>[];

      for (var item in items) {
        try {
          // Try to fetch build from API
          final buildId = int.tryParse(item.id);
          if (buildId != null) {
            final build = await _buildRepository.getBuildById(buildId);
            if (build != null) {
              builds.add(build);
            }
          }
        } catch (e) {
          _logger.w('Failed to fetch build ${item.id}: $e');
        }
      }

      _logger.d('Retrieved ${builds.length} wishlist builds');
      return builds;
    } catch (e) {
      _logger.e('Failed to get wishlist builds: $e');
      return [];
    }
  }

  /// Calculate total value of wishlist items
  Future<double> getTotalValue() async {
    try {
      double total = 0.0;

      // Add component values
      final components = await getWishlistComponents();
      for (var component in components) {
        total += component.priceBdt ?? 0.0;
      }

      // Add build values
      final builds = await getWishlistBuilds();
      for (var build in builds) {
        total += build.totalCost;
      }

      _logger.d('Total wishlist value: $total BDT');
      return total;
    } catch (e) {
      _logger.e('Failed to calculate total wishlist value: $e');
      return 0.0;
    }
  }

  /// Get wishlist count
  Future<int> getCount() async {
    try {
      return await _wishlistRepository.getCount();
    } catch (e) {
      _logger.e('Failed to get wishlist count: $e');
      return 0;
    }
  }

  /// Get component count
  Future<int> getComponentCount() async {
    try {
      return await _wishlistRepository.getCountByType(WishlistItemType.component);
    } catch (e) {
      _logger.e('Failed to get component count: $e');
      return 0;
    }
  }

  /// Get build count
  Future<int> getBuildCount() async {
    try {
      return await _wishlistRepository.getCountByType(WishlistItemType.build);
    } catch (e) {
      _logger.e('Failed to get build count: $e');
      return 0;
    }
  }

  /// Clear the entire wishlist
  Future<bool> clearWishlist() async {
    try {
      final result = await _wishlistRepository.clearWishlist();
      if (result) {
        _logger.i('Cleared wishlist');
      }
      return result;
    } catch (e) {
      _logger.e('Failed to clear wishlist: $e');
      return false;
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _wishlistRepository.dispose();
  }
}
