import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../models/wishlist_item.dart';

/// Repository for managing wishlist items with persistent storage using Hive
class WishlistRepository {
  static const String _wishlistBoxName = 'wishlist';

  final Logger _logger = Logger();
  Box<Map>? _wishlistBox;

  /// Initialize the wishlist box
  Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(_wishlistBoxName)) {
        _wishlistBox = await Hive.openBox<Map>(_wishlistBoxName);
      } else {
        _wishlistBox = Hive.box<Map>(_wishlistBoxName);
      }
      _logger.i('WishlistRepository initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize WishlistRepository: $e');
      rethrow;
    }
  }

  /// Ensure box is open before operations
  Future<void> _ensureBoxOpen() async {
    if (_wishlistBox == null || !_wishlistBox!.isOpen) {
      await init();
    }
  }

  /// Add an item to the wishlist
  Future<bool> addItem(WishlistItem item) async {
    try {
      await _ensureBoxOpen();

      final key = _getKey(item.id, item.type);
      await _wishlistBox!.put(key, item.toJson());

      _logger.d('Added item to wishlist: ${item.id}');
      return true;
    } catch (e) {
      _logger.e('Failed to add item to wishlist: $e');
      return false;
    }
  }

  /// Remove an item from the wishlist
  Future<bool> removeItem(String id, WishlistItemType type) async {
    try {
      await _ensureBoxOpen();

      final key = _getKey(id, type);
      await _wishlistBox!.delete(key);

      _logger.d('Removed item from wishlist: $id');
      return true;
    } catch (e) {
      _logger.e('Failed to remove item from wishlist: $e');
      return false;
    }
  }

  /// Check if an item is in the wishlist
  Future<bool> isInWishlist(String id, WishlistItemType type) async {
    try {
      await _ensureBoxOpen();

      final key = _getKey(id, type);
      return _wishlistBox!.containsKey(key);
    } catch (e) {
      _logger.e('Failed to check if item is in wishlist: $e');
      return false;
    }
  }

  /// Get all wishlist items
  Future<List<WishlistItem>> getAllItems() async {
    try {
      await _ensureBoxOpen();

      final items = <WishlistItem>[];

      for (var entry in _wishlistBox!.values) {
        try {
          final item = WishlistItem.fromJson(
            Map<String, dynamic>.from(entry),
          );
          items.add(item);
        } catch (e) {
          _logger.w('Failed to parse wishlist item: $e');
        }
      }

      // Sort by added date (most recent first)
      items.sort((a, b) => b.addedAt.compareTo(a.addedAt));

      _logger.d('Retrieved ${items.length} wishlist items');
      return items;
    } catch (e) {
      _logger.e('Failed to get wishlist items: $e');
      return [];
    }
  }

  /// Get wishlist items by type
  Future<List<WishlistItem>> getItemsByType(WishlistItemType type) async {
    try {
      final allItems = await getAllItems();
      final filtered = allItems.where((item) => item.type == type).toList();

      _logger.d('Retrieved ${filtered.length} wishlist items of type $type');
      return filtered;
    } catch (e) {
      _logger.e('Failed to get wishlist items by type: $e');
      return [];
    }
  }

  /// Clear all wishlist items
  Future<bool> clearWishlist() async {
    try {
      await _ensureBoxOpen();

      await _wishlistBox!.clear();
      _logger.d('Cleared wishlist');
      return true;
    } catch (e) {
      _logger.e('Failed to clear wishlist: $e');
      return false;
    }
  }

  /// Get wishlist count
  Future<int> getCount() async {
    try {
      await _ensureBoxOpen();
      return _wishlistBox!.length;
    } catch (e) {
      _logger.e('Failed to get wishlist count: $e');
      return 0;
    }
  }

  /// Get count by type
  Future<int> getCountByType(WishlistItemType type) async {
    try {
      final items = await getItemsByType(type);
      return items.length;
    } catch (e) {
      _logger.e('Failed to get wishlist count by type: $e');
      return 0;
    }
  }

  /// Generate a unique key for storage
  String _getKey(String id, WishlistItemType type) {
    return '${type.toString().split('.').last}_$id';
  }

  /// Close the box
  Future<void> dispose() async {
    try {
      if (_wishlistBox?.isOpen == true) {
        await _wishlistBox!.close();
      }
      _logger.i('WishlistRepository disposed');
    } catch (e) {
      _logger.e('Failed to dispose WishlistRepository: $e');
    }
  }
}
