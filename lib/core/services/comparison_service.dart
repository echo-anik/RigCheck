import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/component.dart';
import 'local_storage_service.dart';
import '../../presentation/providers/component_provider.dart';

/// Service for managing component comparison
class ComparisonService {
  final LocalStorageService _localStorage;
  static const String _storageKey = 'comparison_components';
  static const int maxComparisonItems = 4;

  ComparisonService(this._localStorage);

  /// Get all components in comparison
  Future<List<Component>> getComparisonComponents() async {
    try {
      final componentsJson = await _localStorage.getData(_storageKey);
      if (componentsJson == null) return [];

      final List<dynamic> jsonList = componentsJson as List<dynamic>;
      return jsonList
          .map((json) => Component.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Add component to comparison
  Future<bool> addToComparison(Component component) async {
    try {
      final components = await getComparisonComponents();

      // Check if already in comparison
      if (components.any((c) => c.productId == component.productId)) {
        return false; // Already in comparison
      }

      // Check if max items reached
      if (components.length >= maxComparisonItems) {
        return false; // Max items reached
      }

      // Check if category matches (all components must be same category)
      if (components.isNotEmpty &&
          components.first.category != component.category) {
        return false; // Different category
      }

      components.add(component);
      await _saveComponents(components);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove component from comparison
  Future<bool> removeFromComparison(String productId) async {
    try {
      final components = await getComparisonComponents();
      components.removeWhere((c) => c.productId == productId);
      await _saveComponents(components);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all comparison components
  Future<bool> clearComparison() async {
    try {
      await _localStorage.removeData(_storageKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if component is in comparison
  Future<bool> isInComparison(String productId) async {
    final components = await getComparisonComponents();
    return components.any((c) => c.productId == productId);
  }

  /// Get comparison count
  Future<int> getComparisonCount() async {
    final components = await getComparisonComponents();
    return components.length;
  }

  /// Check if can add more components
  Future<bool> canAddMore() async {
    final count = await getComparisonCount();
    return count < maxComparisonItems;
  }

  /// Get category of comparison (null if empty)
  Future<String?> getComparisonCategory() async {
    final components = await getComparisonComponents();
    return components.isEmpty ? null : components.first.category;
  }

  /// Save components to storage
  Future<void> _saveComponents(List<Component> components) async {
    final jsonList = components.map((c) => c.toJson()).toList();
    await _localStorage.saveData(_storageKey, jsonList);
  }

  /// Extract all unique specification keys from components
  List<String> extractSpecificationKeys(List<Component> components) {
    final Set<String> allKeys = {};

    for (final component in components) {
      if (component.specs != null) {
        allKeys.addAll(component.specs!.keys);
      }
    }

    return allKeys.toList()..sort();
  }

  /// Get display value for a specification
  String getSpecDisplayValue(dynamic value) {
    if (value == null) return '-';
    if (value is List) {
      return value.join(' ');
    }
    if (value is Map) {
      return value.values.join(' ');
    }
    return value.toString();
  }

  /// Format specification key for display
  String formatSpecKey(String key) {
    // Convert snake_case to Title Case
    return key
        .split('_')
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  /// Check if specification values differ
  bool specValuesAreDifferent(List<Component> components, String specKey) {
    if (components.isEmpty) return false;

    final values = components
        .map((c) => c.specs?[specKey])
        .map((v) => getSpecDisplayValue(v))
        .toSet();

    return values.length > 1;
  }

  /// Get category-specific important specs (ordered)
  List<String> getCategoryImportantSpecs(String category) {
    switch (category.toLowerCase()) {
      case 'cpu':
        return [
          'core_count',
          'thread_count',
          'core_clock',
          'boost_clock',
          'tdp',
          'integrated_graphics',
          'socket',
          'microarchitecture',
        ];
      case 'video_card':
      case 'video-card':
        return [
          'chipset',
          'memory',
          'core_clock',
          'boost_clock',
          'length',
          'tdp',
          'interface',
        ];
      case 'motherboard':
        return [
          'socket',
          'form_factor',
          'chipset',
          'memory_max',
          'memory_slots',
          'color',
        ];
      case 'memory':
        return [
          'speed',
          'modules',
          'price_per_gb',
          'color',
          'first_word_latency',
          'cas_latency',
        ];
      case 'internal_hard_drive':
      case 'internal-hard-drive':
        return [
          'capacity',
          'type',
          'cache',
          'form_factor',
          'interface',
        ];
      case 'power_supply':
      case 'power-supply':
        return [
          'wattage',
          'type',
          'efficiency',
          'modular',
          'color',
        ];
      case 'case':
        return [
          'type',
          'color',
          'side_panel',
          'external_volume',
          'internal_35_bays',
        ];
      case 'cpu_cooler':
      case 'cpu-cooler':
        return [
          'fan_rpm',
          'noise_level',
          'color',
          'height',
        ];
      default:
        return [];
    }
  }

  /// Get ordered specification keys (important specs first, then alphabetically)
  List<String> getOrderedSpecKeys(List<Component> components) {
    if (components.isEmpty) return [];

    final category = components.first.category;
    final allKeys = extractSpecificationKeys(components);
    final importantSpecs = getCategoryImportantSpecs(category);

    // Split keys into important and other
    final important = <String>[];
    final other = <String>[];

    for (final key in allKeys) {
      if (importantSpecs.contains(key)) {
        important.add(key);
      } else {
        other.add(key);
      }
    }

    // Sort important specs by their order in the important list
    important.sort((a, b) {
      final aIndex = importantSpecs.indexOf(a);
      final bIndex = importantSpecs.indexOf(b);
      return aIndex.compareTo(bIndex);
    });

    // Sort other specs alphabetically
    other.sort();

    return [...important, ...other];
  }
}

/// Provider for ComparisonService
final comparisonServiceProvider = Provider<ComparisonService>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  return ComparisonService(localStorage);
});

/// Provider for comparison components
final comparisonComponentsProvider =
    FutureProvider<List<Component>>((ref) async {
  final service = ref.watch(comparisonServiceProvider);
  return service.getComparisonComponents();
});

/// Provider for comparison count
final comparisonCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(comparisonServiceProvider);
  return service.getComparisonCount();
});

/// Provider for checking if a component is in comparison
final isInComparisonProvider =
    FutureProvider.family<bool, String>((ref, productId) async {
  final service = ref.watch(comparisonServiceProvider);
  return service.isInComparison(productId);
});

/// Provider for comparison category
final comparisonCategoryProvider = FutureProvider<String?>((ref) async {
  final service = ref.watch(comparisonServiceProvider);
  return service.getComparisonCategory();
});
