import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/component.dart';
import '../../data/repositories/component_repository.dart';
import '../../core/services/local_storage_service.dart';
import 'auth_provider.dart';

// Local Storage Service Provider
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

// Component Repository Provider
final componentRepositoryProvider = Provider<ComponentRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  return ComponentRepository(apiClient, localStorage);
});

// Component List Provider
final componentListProvider = FutureProvider.family<List<Component>, String?>((ref, category) async {
  final repository = ref.watch(componentRepositoryProvider);
  return await repository.getAllComponents(category: category);
});

// Component State
class ComponentState {
  final List<Component> components;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;
  final String sortBy;
  final bool showInStockOnly;
  final bool showOnSaleOnly;
  final bool showFeaturedOnly;

  ComponentState({
    this.components = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
    this.sortBy = 'popular',
    this.showInStockOnly = false,
    this.showOnSaleOnly = false,
    this.showFeaturedOnly = false,
  });

  ComponentState copyWith({
    List<Component>? components,
    bool? isLoading,
    String? error,
    String? selectedCategory,
    String? sortBy,
    bool? showInStockOnly,
    bool? showOnSaleOnly,
    bool? showFeaturedOnly,
  }) {
    return ComponentState(
      components: components ?? this.components,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortBy: sortBy ?? this.sortBy,
      showInStockOnly: showInStockOnly ?? this.showInStockOnly,
      showOnSaleOnly: showOnSaleOnly ?? this.showOnSaleOnly,
      showFeaturedOnly: showFeaturedOnly ?? this.showFeaturedOnly,
    );
  }
}

// Component Notifier
class ComponentNotifier extends StateNotifier<ComponentState> {
  final ComponentRepository _repository;

  ComponentNotifier(this._repository) : super(ComponentState());

  Future<void> loadComponents({String? category}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final components = await _repository.getAllComponents(
        category: category,
        sortBy: state.sortBy,
        inStockOnly: state.showInStockOnly,
        onSaleOnly: state.showOnSaleOnly,
        featuredOnly: state.showFeaturedOnly,
      );

      state = state.copyWith(
        components: components,
        isLoading: false,
        selectedCategory: category,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> searchComponents(String query, {String? category}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final components = await _repository.searchComponents(
        query,
        category: category,
        sortBy: state.sortBy,
        inStockOnly: state.showInStockOnly,
        onSaleOnly: state.showOnSaleOnly,
        featuredOnly: state.showFeaturedOnly,
      );

      state = state.copyWith(
        components: components,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> loadComponentsByCategory(String category) async {
    state = state.copyWith(isLoading: true, error: null, selectedCategory: category);

    try {
      final components = await _repository.getAllComponents(
        category: category,
        sortBy: state.sortBy,
        inStockOnly: state.showInStockOnly,
        onSaleOnly: state.showOnSaleOnly,
        featuredOnly: state.showFeaturedOnly,
      );

      state = state.copyWith(
        components: components,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
    loadComponents(category: category);
  }

  /// Update sort order and reload components
  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
    loadComponents(category: state.selectedCategory);
  }

  /// Toggle in-stock filter
  void toggleInStockFilter() {
    state = state.copyWith(showInStockOnly: !state.showInStockOnly);
    loadComponents(category: state.selectedCategory);
  }

  /// Toggle on-sale filter
  void toggleOnSaleFilter() {
    state = state.copyWith(showOnSaleOnly: !state.showOnSaleOnly);
    loadComponents(category: state.selectedCategory);
  }

  /// Toggle featured filter
  void toggleFeaturedFilter() {
    state = state.copyWith(showFeaturedOnly: !state.showFeaturedOnly);
    loadComponents(category: state.selectedCategory);
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(
      showInStockOnly: false,
      showOnSaleOnly: false,
      showFeaturedOnly: false,
    );
    loadComponents(category: state.selectedCategory);
  }
}

// Component Provider
final componentProvider = StateNotifierProvider<ComponentNotifier, ComponentState>((ref) {
  final repository = ref.watch(componentRepositoryProvider);
  return ComponentNotifier(repository);
});
