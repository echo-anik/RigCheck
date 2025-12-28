import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/component.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/local_storage_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ComponentRepository {
  final ApiClient _apiClient;
  final LocalStorageService _localStorage;

  ComponentRepository(this._apiClient, this._localStorage);

  /// Maps frontend category names to backend API categories
  Future<List<Component>> getAllComponents({
    String? category,
    int? page,
    int? perPage,
    String? sortBy,
    bool? inStockOnly,
    bool? onSaleOnly,
    bool? featuredOnly,
  }) async {
    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    final bool isOnline = connectivityResult.first != ConnectivityResult.none;

    // Try to load from cache first (offline-first strategy)
    final cachedComponents = await _localStorage.getAllCachedComponents(category: category);

    if (!isOnline) {
      // Offline: return cached data
      return _applyFiltersAndSorting(
        cachedComponents,
        sortBy: sortBy,
        inStockOnly: inStockOnly,
        onSaleOnly: onSaleOnly,
        featuredOnly: featuredOnly,
      );
    }

    // Online: fetch from API and update cache
    try {
      final queryParams = <String, dynamic>{};

      if (category != null) {
        queryParams['category'] = _mapCategory(category);
      }
      if (page != null) {
        queryParams['page'] = page;
      }
      if (perPage != null) {
        queryParams['per_page'] = perPage;
      }
      if (sortBy != null) {
        queryParams['sort'] = sortBy;
      }

      final response = await _apiClient.get(
        ApiConstants.components,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final components = response.data['data'] as List;
        var componentList = components
            .map((json) => Component.fromJson(json as Map<String, dynamic>))
            .toList();

        // Cache the components for offline use
        await _localStorage.cacheComponents(componentList);

        // Apply local filters and sorting if needed
        componentList = _applyFiltersAndSorting(
          componentList,
          sortBy: sortBy,
          inStockOnly: inStockOnly,
          onSaleOnly: onSaleOnly,
          featuredOnly: featuredOnly,
        );

        return componentList;
      }

      // If API fails, return cached data
      return _applyFiltersAndSorting(
        cachedComponents,
        sortBy: sortBy,
        inStockOnly: inStockOnly,
        onSaleOnly: onSaleOnly,
        featuredOnly: featuredOnly,
      );
    } catch (e) {
      // On error, return cached data if available, otherwise mock data
      if (cachedComponents.isNotEmpty) {
        return _applyFiltersAndSorting(
          cachedComponents,
          sortBy: sortBy,
          inStockOnly: inStockOnly,
          onSaleOnly: onSaleOnly,
          featuredOnly: featuredOnly,
        );
      }

      // Fallback to mock data
      var components = MockDataService.getMockComponents(category: category);
      return _applyFiltersAndSorting(
        components,
        sortBy: sortBy,
        inStockOnly: inStockOnly,
        onSaleOnly: onSaleOnly,
        featuredOnly: featuredOnly,
      );
    }
  }

  Future<Component?> getComponentById(String productId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.componentById(productId),
      );

      if (response.statusCode == 200) {
        final componentData = response.data['data'] as Map<String, dynamic>;
        return Component.fromJson(componentData);
      }

      return null;
    } catch (e) {
      print('Error fetching component by ID: $e');
      rethrow;
    }
  }

  Future<List<Component>> searchComponents(
    String query, {
    String? category,
    String? sortBy,
    bool? inStockOnly,
    bool? onSaleOnly,
    bool? featuredOnly,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'search': query,
      };

      if (category != null) {
        queryParams['category'] = _mapCategory(category);
      }
      if (sortBy != null) {
        queryParams['sort'] = sortBy;
      }

      final response = await _apiClient.get(
        ApiConstants.components,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final components = response.data['data'] as List;
        var componentList = components
            .map((json) => Component.fromJson(json as Map<String, dynamic>))
            .toList();

        // Apply local filters and sorting
        componentList = _applyFiltersAndSorting(
          componentList,
          sortBy: sortBy,
          inStockOnly: inStockOnly,
          onSaleOnly: onSaleOnly,
          featuredOnly: featuredOnly,
        );

        return componentList;
      }

      return [];
    } catch (e) {
      print('Error searching components: $e');
      rethrow;
    }
  }

  /// Apply filters and sorting to a list of components
  List<Component> _applyFiltersAndSorting(
    List<Component> components, {
    String? sortBy,
    bool? inStockOnly,
    bool? onSaleOnly,
    bool? featuredOnly,
  }) {
    var filtered = components;

    // Apply filters
    if (inStockOnly == true) {
      filtered = filtered.where((component) {
        return component.availabilityStatus?.toLowerCase() == 'in_stock' ||
            component.availabilityStatus?.toLowerCase() == 'in stock';
      }).toList();
    }

    if (onSaleOnly == true) {
      filtered = filtered.where((component) {
        // Check if component has a discount or is on sale
        // This could be enhanced with more sophisticated logic
        return component.availabilityStatus?.toLowerCase().contains('sale') == true;
      }).toList();
    }

    if (featuredOnly == true) {
      filtered = filtered.where((component) {
        return component.featured == true;
      }).toList();
    }

    // Apply sorting
    if (sortBy != null) {
      filtered = _sortComponents(filtered, sortBy);
    }

    return filtered;
  }

  /// Sort components based on sort criteria
  List<Component> _sortComponents(List<Component> components, String sortBy) {
    final sorted = List<Component>.from(components);

    switch (sortBy) {
      case 'popular':
        sorted.sort((a, b) {
          final aScore = a.popularityScore ?? 0;
          final bScore = b.popularityScore ?? 0;
          return bScore.compareTo(aScore); // Descending
        });
        break;

      case 'price_asc':
        sorted.sort((a, b) {
          final aPrice = a.priceBdt ?? double.infinity;
          final bPrice = b.priceBdt ?? double.infinity;
          return aPrice.compareTo(bPrice); // Ascending
        });
        break;

      case 'price_desc':
        sorted.sort((a, b) {
          final aPrice = a.priceBdt ?? 0;
          final bPrice = b.priceBdt ?? 0;
          return bPrice.compareTo(aPrice); // Descending
        });
        break;

      case 'newest':
        // Since Component model doesn't have createdAt, we'll use id as proxy
        // Assuming higher IDs are newer components
        sorted.sort((a, b) => b.id.compareTo(a.id)); // Descending
        break;

      default:
        // Default to popular
        sorted.sort((a, b) {
          final aScore = a.popularityScore ?? 0;
          final bScore = b.popularityScore ?? 0;
          return bScore.compareTo(aScore);
        });
    }

    return sorted;
  }

  /// Maps frontend category names to backend API categories
  String _mapCategory(String category) {
    const categoryMap = {
      'memory': 'ram',
      'video-card': 'gpu',
      'internal-hard-drive': 'storage',
      'cpu-cooler': 'cooler',
      'power-supply': 'psu',
      // Direct mappings (no change)
      'cpu': 'cpu',
      'motherboard': 'motherboard',
      'case': 'case',
    };
    
    return categoryMap[category] ?? category;
  }

  /// Search and filter components with comprehensive parameters
  Future<List<Component>> searchAndFilter({
    String? query,
    String? category,
    String? sortBy,
    bool? inStockOnly,
    bool? onSaleOnly,
    bool? featuredOnly,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{};

      if (query != null && query.isNotEmpty) {
        queryParams['search'] = query;
      }
      if (category != null) {
        queryParams['category'] = category;
      }
      if (sortBy != null) {
        queryParams['sort'] = sortBy;
      }

      final response = await _apiClient.get(
        ApiConstants.components,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final components = response.data['data'] as List;
        var componentList = components
            .map((json) => Component.fromJson(json as Map<String, dynamic>))
            .toList();

        // Apply price range filter
        if (minPrice != null || maxPrice != null) {
          componentList = componentList.where((component) {
            if (component.priceBdt == null) return false;
            if (minPrice != null && component.priceBdt! < minPrice) return false;
            if (maxPrice != null && component.priceBdt! > maxPrice) return false;
            return true;
          }).toList();
        }

        // Apply other filters and sorting
        componentList = _applyFiltersAndSorting(
          componentList,
          sortBy: sortBy,
          inStockOnly: inStockOnly,
          onSaleOnly: onSaleOnly,
          featuredOnly: featuredOnly,
        );

        return componentList;
      }

      return [];
    } catch (e) {
      print('Error fetching components by category: $e');
      rethrow;
    }
  }
}
