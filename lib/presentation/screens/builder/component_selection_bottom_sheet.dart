import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// AppColors removed - using theme
import '../../../data/models/component.dart';
import '../../../data/models/build.dart';
import '../../providers/component_provider.dart';
import 'component_detail_sheet.dart';

/// Bottom sheet for selecting components - replaces full-screen navigation
/// Provides better UX with context preservation and faster interaction
class ComponentSelectionBottomSheet extends ConsumerStatefulWidget {
  final String category;
  final String categoryName;
  final Component? currentComponent;
  final Build? currentBuild;
  final ScrollController scrollController;
  final Function(Component) onSelect;

  const ComponentSelectionBottomSheet({
    super.key,
    required this.category,
    required this.categoryName,
    this.currentComponent,
    this.currentBuild,
    required this.scrollController,
    required this.onSelect,
  });

  @override
  ConsumerState<ComponentSelectionBottomSheet> createState() =>
      _ComponentSelectionBottomSheetState();
}

class _ComponentSelectionBottomSheetState
    extends ConsumerState<ComponentSelectionBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'popular';
  RangeValues _priceRange = const RangeValues(0, 100000);
  List<String> _selectedBrands = [];
  bool _inStockOnly = false;
  bool _compatibleOnly = false;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    // Load components for this category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(componentProvider.notifier)
          .loadComponentsByCategory(widget.category);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      ref
          .read(componentProvider.notifier)
          .loadComponentsByCategory(widget.category);
    } else {
      ref.read(componentProvider.notifier).searchComponents(
            query,
            category: widget.category,
          );
    }
  }

  void _showComponentDetail(Component component) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => ComponentDetailSheet(
          component: component,
          onAddToBuild: () {
            // Close both sheets and add to build
            Navigator.of(context).pop(); // Close detail
            widget.onSelect(component); // This will close selection sheet too
          },
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildFilterSheet(),
    );
  }

  Widget _buildFilterSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _priceRange = const RangeValues(0, 100000);
                    _selectedBrands = [];
                    _inStockOnly = false;
                    _compatibleOnly = false;
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sort By
          const Text(
            'Sort By',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Popular'),
                selected: _sortBy == 'popular',
                onSelected: (selected) {
                  if (selected) setState(() => _sortBy = 'popular');
                },
              ),
              ChoiceChip(
                label: const Text('Price: Low to High'),
                selected: _sortBy == 'price_asc',
                onSelected: (selected) {
                  if (selected) setState(() => _sortBy = 'price_asc');
                },
              ),
              ChoiceChip(
                label: const Text('Price: High to Low'),
                selected: _sortBy == 'price_desc',
                onSelected: (selected) {
                  if (selected) setState(() => _sortBy = 'price_desc');
                },
              ),
              ChoiceChip(
                label: const Text('Name A-Z'),
                selected: _sortBy == 'name',
                onSelected: (selected) {
                  if (selected) setState(() => _sortBy = 'name');
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Price Range
          const Text(
            'Price Range',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 100000,
            divisions: 100,
            labels: RangeLabels(
              '৳${_priceRange.start.round()}',
              '৳${_priceRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() => _priceRange = values);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('৳${_priceRange.start.round()}'),
              Text('৳${_priceRange.end.round()}'),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Filters
          const Text(
            'Quick Filters',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('In Stock Only'),
            value: _inStockOnly,
            onChanged: (value) {
              setState(() => _inStockOnly = value);
            },
          ),
          SwitchListTile(
            title: const Text('Compatible Only'),
            subtitle: const Text('Show only compatible with current build'),
            value: _compatibleOnly,
            onChanged: (value) {
              setState(() => _compatibleOnly = value);
            },
          ),

          const SizedBox(height: 20),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _applyFilters();
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    // Update component provider with new sorting and filtering
    ref.read(componentProvider.notifier).setSortBy(_sortBy);
    // Reload components with filters
    ref
        .read(componentProvider.notifier)
        .loadComponentsByCategory(widget.category);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters applied'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  bool get hasActiveFilters =>
      _priceRange.start != 0 ||
      _priceRange.end != 100000 ||
      _selectedBrands.isNotEmpty ||
      _inStockOnly ||
      _compatibleOnly;

  int get activeFilterCount {
    int count = 0;
    if (_priceRange.start != 0 || _priceRange.end != 100000) count++;
    if (_selectedBrands.isNotEmpty) count++;
    if (_inStockOnly) count++;
    if (_compatibleOnly) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final componentState = ref.watch(componentProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select ${widget.categoryName}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search components...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _performSearch,
            ),
          ),

          const SizedBox(height: 12),

          // Filter Chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Filters'),
                      if (hasActiveFilters) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$activeFilterCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  onSelected: (_) => _showFilterSheet(),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('In Stock'),
                  selected: _inStockOnly,
                  onSelected: (selected) {
                    setState(() => _inStockOnly = selected);
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Compatible'),
                  selected: _compatibleOnly,
                  onSelected: (selected) {
                    setState(() => _compatibleOnly = selected);
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Popular'),
                  selected: _sortBy == 'popular',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _sortBy = 'popular');
                      _applyFilters();
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Price ↓'),
                  selected: _sortBy == 'price_asc',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _sortBy = 'price_asc');
                      _applyFilters();
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // Component Grid
          Expanded(
            child: componentState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : componentState.error != null
                    ? Center(child: Text('Error: ${componentState.error}'))
                    : componentState.components.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No components found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your filters',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            controller: widget.scrollController,
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: componentState.components.length,
                            itemBuilder: (context, index) {
                              final component = componentState.components[index];
                              final isSelected =
                                  widget.currentComponent?.id == component.id;

                              return GestureDetector(
                                onTap: () => widget.onSelect(component),
                                onLongPress: () => _showComponentDetail(component),
                                child: Card(
                                  elevation: isSelected ? 4 : 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: isSelected
                                        ? BorderSide(
                                            color: Theme.of(context).colorScheme.primary,
                                            width: 2,
                                          )
                                        : BorderSide.none,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Image
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                          ),
                                          child: Center(
                                            child: component.imageUrl != null
                                                ? Image.network(
                                                    component.imageUrl!,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Icon(
                                                    Icons.memory,
                                                    size: 48,
                                                    color: Colors.grey[400],
                                                  ),
                                          ),
                                        ),
                                      ),

                                      // Info
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              component.name,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              component.brand,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              component.priceBdt != null
                                                  ? '\$${(component.priceBdt! / 120).toStringAsFixed(2)}'
                                                  : 'N/A',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.info_outline,
                                                  size: 14,
                                                  color: Colors.grey[500],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Long press for details',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
