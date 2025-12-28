import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../../data/models/component.dart';
import '../../data/models/build.dart';

/// Service for managing local cache and offline storage using Hive
class LocalStorageService {
  static const String _componentCacheBoxName = 'component_cache';
  static const String _buildCacheBoxName = 'build_cache';
  static const String _metadataBoxName = 'cache_metadata';
  static const String _syncStatusKey = 'sync_status';
  static const String _lastSyncKey = 'last_sync';
  static const String _offlineModeKey = 'offline_mode';

  final Logger _logger = Logger();

  Box<Map>? _componentCacheBox;
  Box<Map>? _buildCacheBox;
  Box<dynamic>? _metadataBox;

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

  /// Initialize Hive boxes for local storage
  Future<void> init() async {
    try {
      await Hive.initFlutter();

      // Open boxes if not already open
      if (!Hive.isBoxOpen(_componentCacheBoxName)) {
        _componentCacheBox = await Hive.openBox<Map>(_componentCacheBoxName);
      } else {
        _componentCacheBox = Hive.box<Map>(_componentCacheBoxName);
      }

      if (!Hive.isBoxOpen(_buildCacheBoxName)) {
        _buildCacheBox = await Hive.openBox<Map>(_buildCacheBoxName);
      } else {
        _buildCacheBox = Hive.box<Map>(_buildCacheBoxName);
      }

      if (!Hive.isBoxOpen(_metadataBoxName)) {
        _metadataBox = await Hive.openBox(_metadataBoxName);
      } else {
        _metadataBox = Hive.box(_metadataBoxName);
      }

      _logger.i('LocalStorageService initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize LocalStorageService: $e');
      rethrow;
    }
  }

  // ==================== Component Cache ====================

  /// Cache a single component
  Future<bool> cacheComponent(Component component) async {
    try {
      await _ensureBoxesOpen();

      final key = component.id.toString();
      final data = {
        ..._serializeComponent(component),
        'cached_at': DateTime.now().toIso8601String(),
      };

      await _componentCacheBox!.put(key, data);
      _logger.d('Cached component: ${component.name}');

      return true;
    } catch (e) {
      _logger.e('Failed to cache component: $e');
      return false;
    }
  }

  /// Cache multiple components
  Future<bool> cacheComponents(List<Component> components) async {
    try {
      await _ensureBoxesOpen();

      final Map<String, Map> cacheData = {};
      final now = DateTime.now().toIso8601String();

      for (var component in components) {
        final key = component.id.toString();
        cacheData[key] = {
          ..._serializeComponent(component),
          'cached_at': now,
        };
      }

      await _componentCacheBox!.putAll(cacheData);
      _logger.d('Cached ${components.length} components');

      return true;
    } catch (e) {
      _logger.e('Failed to cache components: $e');
      return false;
    }
  }

  /// Get cached component by ID
  Future<Component?> getCachedComponent(int componentId) async {
    try {
      await _ensureBoxesOpen();

      final key = componentId.toString();
      final Map<dynamic, dynamic>? data = _componentCacheBox!.get(key);

      if (data == null) {
        return null;
      }

      return Component.fromJson(_normalizeMap(data));
    } catch (e) {
      _logger.e('Failed to get cached component: $e');
      return null;
    }
  }

  /// Get all cached components
  Future<List<Component>> getAllCachedComponents({String? category}) async {
    try {
      await _ensureBoxesOpen();

      final components = <Component>[];

      for (var entry in _componentCacheBox!.values) {
        try {
          final component = Component.fromJson(_normalizeMap(entry));

          // Filter by category if specified
          if (category == null || component.category == category) {
            components.add(component);
          }
        } catch (e) {
          _logger.w('Failed to parse cached component: $e');
        }
      }

      _logger.d('Retrieved ${components.length} cached components');
      return components;
    } catch (e) {
      _logger.e('Failed to get cached components: $e');
      return [];
    }
  }

  /// Search cached components
  Future<List<Component>> searchCachedComponents(String query) async {
    try {
      await _ensureBoxesOpen();

      final allComponents = await getAllCachedComponents();
      final lowercaseQuery = query.toLowerCase();

      final filtered = allComponents.where((component) {
        return component.name.toLowerCase().contains(lowercaseQuery) ||
            component.brand.toLowerCase().contains(lowercaseQuery) ||
            component.category.toLowerCase().contains(lowercaseQuery);
      }).toList();

      _logger.d('Found ${filtered.length} components matching "$query"');
      return filtered;
    } catch (e) {
      _logger.e('Failed to search cached components: $e');
      return [];
    }
  }

  /// Clear component cache
  Future<bool> clearComponentCache() async {
    try {
      await _ensureBoxesOpen();

      await _componentCacheBox!.clear();
      _logger.d('Cleared component cache');

      return true;
    } catch (e) {
      _logger.e('Failed to clear component cache: $e');
      return false;
    }
  }

  // ==================== Build Cache ====================

  /// Cache a single build
  Future<bool> cacheBuild(Build build) async {
    try {
      await _ensureBoxesOpen();

      final key = build.uuid ?? build.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      final data = {
        ..._serializeBuild(build),
        'cached_at': DateTime.now().toIso8601String(),
      };

      await _buildCacheBox!.put(key, data);
      _logger.d('Cached build: ${build.name}');

      return true;
    } catch (e) {
      _logger.e('Failed to cache build: $e');
      return false;
    }
  }

  /// Cache multiple builds
  Future<bool> cacheBuilds(List<Build> builds) async {
    try {
      await _ensureBoxesOpen();

      final Map<String, Map> cacheData = {};
      final now = DateTime.now().toIso8601String();

      for (var build in builds) {
        final key = build.uuid ?? build.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
        cacheData[key] = {
          ..._serializeBuild(build),
          'cached_at': now,
        };
      }

      await _buildCacheBox!.putAll(cacheData);
      _logger.d('Cached ${builds.length} builds');

      return true;
    } catch (e) {
      _logger.e('Failed to cache builds: $e');
      return false;
    }
  }

  /// Get cached build by key
  Future<Build?> getCachedBuild(String buildKey) async {
    try {
      await _ensureBoxesOpen();

      final Map<dynamic, dynamic>? data = _buildCacheBox!.get(buildKey);

      if (data == null) {
        return null;
      }

      return Build.fromJson(_normalizeMap(data));
    } catch (e) {
      _logger.e('Failed to get cached build: $e');
      return null;
    }
  }

  /// Get all cached builds
  Future<List<Build>> getAllCachedBuilds() async {
    try {
      await _ensureBoxesOpen();

      final builds = <Build>[];

      for (var entry in _buildCacheBox!.values) {
        try {
          final build = Build.fromJson(_normalizeMap(entry));
          builds.add(build);
        } catch (e) {
          _logger.w('Failed to parse cached build: $e');
        }
      }

      // Sort by updated date (most recent first)
      builds.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      _logger.d('Retrieved ${builds.length} cached builds');
      return builds;
    } catch (e) {
      _logger.e('Failed to get cached builds: $e');
      return [];
    }
  }

  /// Clear build cache
  Future<bool> clearBuildCache() async {
    try {
      await _ensureBoxesOpen();

      await _buildCacheBox!.clear();
      _logger.d('Cleared build cache');

      return true;
    } catch (e) {
      _logger.e('Failed to clear build cache: $e');
      return false;
    }
  }

  // ==================== Offline Mode & Sync ====================

  /// Set offline mode status
  Future<bool> setOfflineMode(bool enabled) async {
    try {
      await _ensureBoxesOpen();

      await _metadataBox!.put(_offlineModeKey, enabled);
      _logger.d('Offline mode: ${enabled ? "enabled" : "disabled"}');

      return true;
    } catch (e) {
      _logger.e('Failed to set offline mode: $e');
      return false;
    }
  }

  /// Get offline mode status
  Future<bool> isOfflineMode() async {
    try {
      await _ensureBoxesOpen();

      return _metadataBox!.get(_offlineModeKey, defaultValue: false) as bool;
    } catch (e) {
      _logger.e('Failed to get offline mode status: $e');
      return false;
    }
  }

  /// Update sync status
  Future<bool> updateSyncStatus(Map<String, dynamic> status) async {
    try {
      await _ensureBoxesOpen();

      await _metadataBox!.put(_syncStatusKey, status);
      await _metadataBox!.put(_lastSyncKey, DateTime.now().toIso8601String());

      _logger.d('Updated sync status');
      return true;
    } catch (e) {
      _logger.e('Failed to update sync status: $e');
      return false;
    }
  }

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      await _ensureBoxesOpen();

      final status = _metadataBox!.get(_syncStatusKey);
      if (status == null) {
        return {
          'components_synced': 0,
          'builds_synced': 0,
          'last_sync': null,
          'pending_sync': false,
        };
      }

      return Map<String, dynamic>.from(status);
    } catch (e) {
      _logger.e('Failed to get sync status: $e');
      return {
        'components_synced': 0,
        'builds_synced': 0,
        'last_sync': null,
        'pending_sync': false,
      };
    }
  }

  /// Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    try {
      await _ensureBoxesOpen();

      final lastSyncStr = _metadataBox!.get(_lastSyncKey);
      if (lastSyncStr == null) return null;

      return DateTime.parse(lastSyncStr as String);
    } catch (e) {
      _logger.e('Failed to get last sync time: $e');
      return null;
    }
  }

  // ==================== Cache Management ====================

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      await _ensureBoxesOpen();

      final lastSync = await getLastSyncTime();
      final offlineMode = await isOfflineMode();

      return {
        'component_cache_size': _componentCacheBox!.length,
        'build_cache_size': _buildCacheBox!.length,
        'last_sync': lastSync?.toIso8601String(),
        'offline_mode': offlineMode,
      };
    } catch (e) {
      _logger.e('Failed to get cache stats: $e');
      return {
        'component_cache_size': 0,
        'build_cache_size': 0,
        'last_sync': null,
        'offline_mode': false,
      };
    }
  }

  /// Clear all cache
  Future<bool> clearAllCache() async {
    try {
      await clearComponentCache();
      await clearBuildCache();
      await _metadataBox!.clear();

      _logger.d('Cleared all cache');
      return true;
    } catch (e) {
      _logger.e('Failed to clear all cache: $e');
      return false;
    }
  }

  /// Remove old cache entries (older than specified days)
  Future<bool> removeOldCache({int olderThanDays = 30}) async {
    try {
      await _ensureBoxesOpen();

      final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));
      int removedCount = 0;

      // Clean component cache
      final componentKeysToRemove = <String>[];
      for (var key in _componentCacheBox!.keys) {
        final data = _componentCacheBox!.get(key);
        if (data != null && data['cached_at'] != null) {
          final cachedAt = DateTime.parse(data['cached_at'] as String);
          if (cachedAt.isBefore(cutoffDate)) {
            componentKeysToRemove.add(key.toString());
          }
        }
      }
      await _componentCacheBox!.deleteAll(componentKeysToRemove);
      removedCount += componentKeysToRemove.length;

      // Clean build cache
      final buildKeysToRemove = <String>[];
      for (var key in _buildCacheBox!.keys) {
        final data = _buildCacheBox!.get(key);
        if (data != null && data['cached_at'] != null) {
          final cachedAt = DateTime.parse(data['cached_at'] as String);
          if (cachedAt.isBefore(cutoffDate)) {
            buildKeysToRemove.add(key.toString());
          }
        }
      }
      await _buildCacheBox!.deleteAll(buildKeysToRemove);
      removedCount += buildKeysToRemove.length;

      _logger.d('Removed $removedCount old cache entries');
      return true;
    } catch (e) {
      _logger.e('Failed to remove old cache: $e');
      return false;
    }
  }

  /// Ensure boxes are open before operations
  Future<void> _ensureBoxesOpen() async {
    if (_componentCacheBox == null || _buildCacheBox == null || _metadataBox == null ||
        !_componentCacheBox!.isOpen || !_buildCacheBox!.isOpen || !_metadataBox!.isOpen) {
      await init();
    }
  }

  // ==================== Generic Data Storage ====================

  /// Save generic data to metadata box
  Future<bool> saveData(String key, dynamic value) async {
    try {
      await _ensureBoxesOpen();
      await _metadataBox!.put(key, value);
      _logger.d('Saved data for key: $key');
      return true;
    } catch (e) {
      _logger.e('Failed to save data: $e');
      return false;
    }
  }

  /// Get generic data from metadata box
  Future<dynamic> getData(String key) async {
    try {
      await _ensureBoxesOpen();
      return _metadataBox!.get(key);
    } catch (e) {
      _logger.e('Failed to get data: $e');
      return null;
    }
  }

  /// Remove generic data from metadata box
  Future<bool> removeData(String key) async {
    try {
      await _ensureBoxesOpen();
      await _metadataBox!.delete(key);
      _logger.d('Removed data for key: $key');
      return true;
    } catch (e) {
      _logger.e('Failed to remove data: $e');
      return false;
    }
  }

  /// Close all boxes
  Future<void> dispose() async {
    try {
      if (_componentCacheBox?.isOpen == true) {
        await _componentCacheBox!.close();
      }
      if (_buildCacheBox?.isOpen == true) {
        await _buildCacheBox!.close();
      }
      if (_metadataBox?.isOpen == true) {
        await _metadataBox!.close();
      }
      _logger.i('LocalStorageService disposed');
    } catch (e) {
      _logger.e('Failed to dispose LocalStorageService: $e');
    }
  }
}
