import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
// AppColors removed - using theme
import '../../../core/constants/app_strings.dart';
import '../../providers/component_provider.dart';
import '../../widgets/component_card.dart';

class ComponentsScreen extends ConsumerStatefulWidget {
  const ComponentsScreen({super.key});

  @override
  ConsumerState<ComponentsScreen> createState() => _ComponentsScreenState();
}

class _ComponentsScreenState extends ConsumerState<ComponentsScreen> {
  final List<Map<String, dynamic>> _categories = [
    {'id': 'cpu', 'name': 'CPU', 'icon': Icons.memory},
    {'id': 'motherboard', 'name': 'Motherboard', 'icon': Icons.developer_board},
    {'id': 'video-card', 'name': 'GPU', 'icon': Icons.videogame_asset},
    {'id': 'memory', 'name': 'RAM', 'icon': Icons.sd_storage},
    {'id': 'internal-hard-drive', 'name': 'Storage', 'icon': Icons.storage},
    {'id': 'power-supply', 'name': 'PSU', 'icon': Icons.power},
    {'id': 'case', 'name': 'Case', 'icon': Icons.computer},
    {'id': 'cpu-cooler', 'name': 'Cooler', 'icon': Icons.ac_unit},
  ];

  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    // Load all components on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(componentProvider.notifier).loadComponents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final componentState = ref.watch(componentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.browseComponents),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push('/search');
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (value) {
              ref.read(componentProvider.notifier).setSortBy(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'popular',
                child: Row(
                  children: [
                    Icon(Icons.trending_up, size: 20),
                    SizedBox(width: 12),
                    Text('Popular'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'price_asc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, size: 20),
                    SizedBox(width: 12),
                    Text('Price: Low to High'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'price_desc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, size: 20),
                    SizedBox(width: 12),
                    Text('Price: High to Low'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'newest',
                child: Row(
                  children: [
                    Icon(Icons.new_releases, size: 20),
                    SizedBox(width: 12),
                    Text('Newest'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 100,
            color: Theme.of(context).colorScheme.surface,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: _categories.length + 1, // +1 for "All" option
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildCategoryChip(
                    label: 'All',
                    icon: Icons.apps,
                    isSelected: componentState.selectedCategory == null,
                    onTap: () {
                      ref
                          .read(componentProvider.notifier)
                          .loadComponents(category: null);
                    },
                  );
                }

                final category = _categories[index - 1];
                return _buildCategoryChip(
                  label: category['name'],
                  icon: category['icon'],
                  isSelected: componentState.selectedCategory == category['id'],
                  onTap: () {
                    ref
                        .read(componentProvider.notifier)
                        .loadComponents(category: category['id']);
                  },
                );
              },
            ),
          ),

          // Quick Filter Pills
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterPill(
                    label: 'In Stock',
                    icon: Icons.check_circle,
                    isSelected: componentState.showInStockOnly,
                    onTap: () {
                      ref.read(componentProvider.notifier).toggleInStockFilter();
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    label: 'On Sale',
                    icon: Icons.local_offer,
                    isSelected: componentState.showOnSaleOnly,
                    onTap: () {
                      ref.read(componentProvider.notifier).toggleOnSaleFilter();
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    label: 'Featured',
                    icon: Icons.star,
                    isSelected: componentState.showFeaturedOnly,
                    onTap: () {
                      ref.read(componentProvider.notifier).toggleFeaturedFilter();
                    },
                  ),
                  const SizedBox(width: 8),
                  // Active filters indicator
                  if (componentState.showInStockOnly ||
                      componentState.showOnSaleOnly ||
                      componentState.showFeaturedOnly)
                    TextButton.icon(
                      onPressed: () {
                        ref.read(componentProvider.notifier).clearFilters();
                      },
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Clear'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Components List
          Expanded(
            child: componentState.isLoading
                ? _buildShimmerLoading()
                : componentState.error != null
                    ? _buildErrorState(componentState.error!)
                    : componentState.components.isEmpty
                        ? _buildEmptyState()
                        : _isGridView
                            ? _buildGridView(componentState.components)
                            : _buildListView(componentState.components),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedColor: Theme.of(context).colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final selectedCategory = ref.read(componentProvider).selectedCategory;
                ref
                    .read(componentProvider.notifier)
                    .loadComponents(category: selectedCategory);
              },
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.noDataAvailable,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(List<dynamic> components) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: components.length,
      itemBuilder: (context, index) {
        final component = components[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to component detail
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Component image
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.computer,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ),
                // Component details
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          component.brand,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          component.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (component.priceBdt != null)
                          Text(
                            '\$${(component.priceBdt! / 120).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView(List<dynamic> components) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: components.length,
      itemBuilder: (context, index) {
        final component = components[index];
        return ComponentCard(component: component);
      },
    );
  }

  Widget _buildShimmerLoading() {
    return _isGridView ? _buildShimmerGrid() : _buildShimmerList();
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          highlightColor: Colors.white,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 10,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          height: 12,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          height: 12,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        const Spacer(),
                        Container(
                          width: 50,
                          height: 14,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          highlightColor: Colors.white,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 12,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 14,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 150,
                          height: 12,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 60,
                          height: 16,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
