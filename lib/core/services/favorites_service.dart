import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../../data/models/component.dart';
import '../../data/models/build.dart';

/// Service for managing favorites using Hive local storage
class FavoritesService {
  static const String _componentBoxName = 'favorite_components';
  static const String _buildBoxName = 'favorite_builds';

  final Logger _logger = Logger();

  Box<Map>? _componentBox;
  Box<Map>? _buildBox;

  Map<String, dynamic> _serializeComponent(Component component) {
    return _normalizeMap(component.toJson());
  }

  Map<String, dynamic> _serializeBuild(Build build) {
    return _normalizeMap(build.toJson());
  }

  Map<String, dynamic> _normalizeMap(Map source) {
    final normalized = <String, dynamic>{};
    source.forEach((key, value) {
      normalized[key.toString()] = _normalizeValue(value);
    });
    return normalized;
  }

  dynamic _normalizeValue(dynamic value) {
    if (value is Map) {
      return _normalizeMap(value);
    }
    if (value is Iterable) {
      return value.map(_normalizeValue).toList();
    }
    return value;
  }

  /// Initialize Hive boxes for favorites
  Future<void> init() async {
    try {
      await Hive.initFlutter();

      // Open boxes if not already open
      if (!Hive.isBoxOpen(_componentBoxName)) {
        _componentBox = await Hive.openBox<Map>(_componentBoxName);
      } else {
        _componentBox = Hive.box<Map>(_componentBoxName);
      }

      if (!Hive.isBoxOpen(_buildBoxName)) {
        _buildBox = await Hive.openBox<Map>(_buildBoxName);
      } else {
        _buildBox = Hive.box<Map>(_buildBoxName);
      }

      _logger.i('FavoritesService initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize FavoritesService: $e');
      rethrow;
    }
  }

  /// Add a component to favorites
  Future<bool> addComponentToFavorites(Component component) async {
    try {
      await _ensureBoxesOpen();

      final key = component.id.toString();
      await _componentBox!.put(key, _serializeComponent(component));
      _logger.d('Added component ${component.name} to favorites');

      return true;
    } catch (e) {
      _logger.e('Failed to add component to favorites: $e');
      return false;
    }
  }

  /// Remove a component from favorites
  Future<bool> removeComponentFromFavorites(int componentId) async {
    try {
      await _ensureBoxesOpen();

      final key = componentId.toString();
      await _componentBox!.delete(key);

      _logger.d('Removed component $componentId from favorites');
      return true;
    } catch (e) {
      _logger.e('Failed to remove component from favorites: $e');
      return false;
    }
  }

  /// Check if a component is favorited
  Future<bool> isComponentFavorited(int componentId) async {
    try {
      await _ensureBoxesOpen();

      final key = componentId.toString();
      return _componentBox!.containsKey(key);
    } catch (e) {
      _logger.e('Failed to check if component is favorited: $e');
      return false;
    }
  }

  /// Get all favorite components
  Future<List<Component>> getAllFavoriteComponents() async {
    try {
      await _ensureBoxesOpen();

      final components = <Component>[];

      for (var entry in _componentBox!.values) {
        try {
          final component = Component.fromJson(_normalizeMap(entry));
          components.add(component);
        } catch (e) {
          _logger.w('Failed to parse component from favorites: $e');
        }
      }

      // Sort by name
      components.sort((a, b) => a.name.compareTo(b.name));

      _logger.d('Retrieved ${components.length} favorite components');
      return components;
    } catch (e) {
      _logger.e('Failed to get favorite components: $e');
      return [];
    }
  }

  /// Add a build to favorites
  Future<bool> addBuildToFavorites(Build build) async {
    try {
      await _ensureBoxesOpen();

      // Use UUID if available, otherwise use ID
      final key = build.uuid ?? build.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();

      await _buildBox!.put(key, _serializeBuild(build));
      _logger.d('Added build ${build.name} to favorites');

      return true;
    } catch (e) {
      _logger.e('Failed to add build to favorites: $e');
      return false;
    }
  }

  /// Remove a build from favorites
  Future<bool> removeBuildFromFavorites(String buildKey) async {
    try {
      await _ensureBoxesOpen();

      await _buildBox!.delete(buildKey);
      _logger.d('Removed build $buildKey from favorites');

      return true;
    } catch (e) {
      _logger.e('Failed to remove build from favorites: $e');
      return false;
    }
  }

  /// Check if a build is favorited
  Future<bool> isBuildFavorited(String buildKey) async {
    try {
      await _ensureBoxesOpen();

      return _buildBox!.containsKey(buildKey);
    } catch (e) {
      _logger.e('Failed to check if build is favorited: $e');
      return false;
    }
  }

  /// Get all favorite builds
  Future<List<Build>> getAllFavoriteBuilds() async {
    try {
      await _ensureBoxesOpen();

      final builds = <Build>[];

      for (var entry in _buildBox!.values) {
        try {
          final build = Build.fromJson(_normalizeMap(entry));
          builds.add(build);
        } catch (e) {
          _logger.w('Failed to parse build from favorites: $e');
        }
      }

      // Sort by updated date (most recent first)
      builds.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      _logger.d('Retrieved ${builds.length} favorite builds');
      return builds;
    } catch (e) {
      _logger.e('Failed to get favorite builds: $e');
      return [];
    }
  }

  /// Get total count of favorites
  Future<Map<String, int>> getFavoritesCount() async {
    try {
      await _ensureBoxesOpen();

      return {
        'components': _componentBox!.length,
        'builds': _buildBox!.length,
      };
    } catch (e) {
      _logger.e('Failed to get favorites count: $e');
      return {'components': 0, 'builds': 0};
    }
  }

  /// Clear all component favorites
  Future<bool> clearComponentFavorites() async {
    try {
      await _ensureBoxesOpen();

      await _componentBox!.clear();
      _logger.d('Cleared all component favorites');

      return true;
    } catch (e) {
      _logger.e('Failed to clear component favorites: $e');
      return false;
    }
  }

  /// Clear all build favorites
  Future<bool> clearBuildFavorites() async {
    try {
      await _ensureBoxesOpen();

      await _buildBox!.clear();
      _logger.d('Cleared all build favorites');

      return true;
    } catch (e) {
      _logger.e('Failed to clear build favorites: $e');
      return false;
    }
  }

  /// Clear all favorites
  Future<bool> clearAllFavorites() async {
    try {
      await clearComponentFavorites();
      await clearBuildFavorites();

      _logger.d('Cleared all favorites');
      return true;
    } catch (e) {
      _logger.e('Failed to clear all favorites: $e');
      return false;
    }
  }

  /// Ensure boxes are open before operations
  Future<void> _ensureBoxesOpen() async {
    if (_componentBox == null || _buildBox == null ||
        !_componentBox!.isOpen || !_buildBox!.isOpen) {
      await init();
    }
  }

  /// Close all boxes
  Future<void> dispose() async {
    try {
      if (_componentBox?.isOpen == true) {
        await _componentBox!.close();
      }
      if (_buildBox?.isOpen == true) {
        await _buildBox!.close();
      }
      _logger.i('FavoritesService disposed');
    } catch (e) {
      _logger.e('Failed to dispose FavoritesService: $e');
    }
  }
}
