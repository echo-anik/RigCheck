import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/build.dart';
import '../../../data/models/component.dart';
import '../../providers/component_provider.dart';
import '../../widgets/component_card.dart';

class ComponentSelectionScreen extends ConsumerStatefulWidget {
  final String category;
  final String categoryName;
  final Component? currentComponent;
  final Build? currentBuild;

  const ComponentSelectionScreen({
    super.key,
    required this.category,
    required this.categoryName,
    this.currentComponent,
    this.currentBuild,
  });

  @override
  ConsumerState<ComponentSelectionScreen> createState() => _ComponentSelectionScreenState();
}

class _ComponentSelectionScreenState extends ConsumerState<ComponentSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  RangeValues _priceRange = const RangeValues(0, 100000);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(componentProvider.notifier).loadComponentsByCategory(widget.category);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final notifier = ref.read(componentProvider.notifier);
    final sanitized = query.trim();
    if (sanitized.isEmpty) {
      await notifier.loadComponentsByCategory(widget.category);
    } else {
      await notifier.searchComponents(sanitized, category: widget.category);
    }
  }

  void _applyFilters() {
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters applied'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 100000);
      _showFilters = false;
    });

    final notifier = ref.read(componentProvider.notifier);
    notifier.clearFilters();
    notifier.setSortBy('popular');
    notifier.loadComponentsByCategory(widget.category);
    _searchController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters reset'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final componentState = ref.watch(componentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select ${widget.categoryName}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showFilters) _buildFilterPanel(componentState),
          Expanded(child: _buildComponentList(componentState)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search ${widget.categoryName}...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                    _performSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: _performSearch,
        onChanged: (_) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildFilterPanel(ComponentState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sort By',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildSortChip('Popular', 'popular', state.sortBy),
              _buildSortChip('Price: Low to High', 'price_asc', state.sortBy),
              _buildSortChip('Price: High to Low', 'price_desc', state.sortBy),
              _buildSortChip('Newest', 'newest', state.sortBy),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Price Range: ৳${_priceRange.start.toInt()} - ৳${_priceRange.end.toInt()}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 200000,
            divisions: 200,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('In Stock'),
                selected: state.showInStockOnly,
                onSelected: (_) => ref.read(componentProvider.notifier).toggleInStockFilter(),
              ),
              FilterChip(
                label: const Text('On Sale'),
                selected: state.showOnSaleOnly,
                onSelected: (_) => ref.read(componentProvider.notifier).toggleOnSaleFilter(),
              ),
              FilterChip(
                label: const Text('Featured'),
                selected: state.showFeaturedOnly,
                onSelected: (_) => ref.read(componentProvider.notifier).toggleFeaturedFilter(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: _resetFilters, child: const Text('Reset')),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value, String currentSort) {
    final isSelected = currentSort == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => ref.read(componentProvider.notifier).setSortBy(value),
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
        fontSize: 13,
      ),
    );
  }

  Widget _buildComponentList(ComponentState state) {
    if (state.isLoading) {
      return _buildLoadingSkeleton();
    }

    if (state.error != null) {
      return _buildErrorState(state.error!);
    }

    final filteredComponents = _getCompatibleComponents(state.components);

    if (filteredComponents.isEmpty) {
      return _buildEmptyState(state.components.isNotEmpty);
    }

    return Column(
      children: [
        if (widget.currentBuild != null && filteredComponents.length < state.components.length)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.filter_alt, size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Showing ${filteredComponents.length} of ${state.components.length} compatible components',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredComponents.length,
            itemBuilder: (context, index) {
              final component = filteredComponents[index];
              final isSelected = widget.currentComponent?.id == component.id;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isSelected
                      ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                      : BorderSide.none,
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.pop(component),
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      ComponentCard(component: component),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: ElevatedButton.icon(
                          onPressed: () => context.pop(component),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            elevation: 4,
                            shadowColor: Colors.black.withOpacity(0.3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check, size: 14, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Selected',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
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
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: () {
                ref.read(componentProvider.notifier).loadComponentsByCategory(widget.category);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool hadComponents) {
    final message = widget.currentBuild != null
        ? 'No components match your current build configuration'
        : hadComponents
            ? 'No components match the selected filters'
            : 'Try different search terms or filters';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text('No compatible components found', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Card(
            child: Container(
              height: 120,
              padding: const EdgeInsets.all(16),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 150,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
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

  List<Component> _getCompatibleComponents(List<Component> components) {
    final priceFiltered = _filterByPriceRange(components);
    final build = widget.currentBuild;
    if (build == null) {
      return priceFiltered;
    }

    return priceFiltered.where((component) => _isComponentCompatible(component, build)).toList();
  }

  List<Component> _filterByPriceRange(List<Component> components) {
    return components.where((component) {
      final price = component.priceBdt;
      if (price == null) {
        return true;
      }
      return price >= _priceRange.start && price <= _priceRange.end;
    }).toList();
  }

  bool _isComponentCompatible(Component component, Build build) {
    switch (widget.category) {
      case 'motherboard':
        return _socketsMatch(build.components['cpu'], component);
      case 'cpu':
        return _socketsMatch(component, build.components['motherboard']);
      case 'memory':
        return _memoryTypesMatch(component, build.components['motherboard']);
      case 'power-supply':
        return _psuHasHeadroom(component, build);
      case 'case':
        final motherboard = build.components['motherboard'];
        final gpu = build.components['video-card'];
        return _caseSupportsMotherboard(motherboard, component) && _gpuFitsCase(gpu, component);
      case 'video-card':
        return _gpuFitsCase(component, build.components['case']);
      default:
        return true;
    }
  }

  bool _socketsMatch(Component? cpu, Component? motherboard) {
    if (cpu == null || motherboard == null) {
      return true;
    }

    final cpuSocket = _normalizeSpecString(cpu.specs?['socket']);
    final mbSocket = _normalizeSpecString(motherboard.specs?['socket']);

    if (cpuSocket == null || mbSocket == null) {
      return true;
    }

    return cpuSocket == mbSocket;
  }

  bool _memoryTypesMatch(Component? memory, Component? motherboard) {
    if (memory == null || motherboard == null) {
      return true;
    }

    final ramType = _extractDdrType(memory);
    final boardType = _extractDdrType(motherboard);

    if (ramType == null || boardType == null) {
      return true;
    }

    return boardType == ramType;
  }

  bool _psuHasHeadroom(Component psu, Build build) {
    final wattage = _parseNumericSpec(psu.specs?['wattage']);
    if (wattage == null) {
      return true;
    }

    final estimatedTdp = _estimateBuildTdp(build);
    if (estimatedTdp == null) {
      return true;
    }

    final recommended = (estimatedTdp * 1.2).ceil();
    return wattage >= recommended;
  }

  bool _caseSupportsMotherboard(Component? motherboard, Component caseComponent) {
    if (motherboard == null) {
      return true;
    }

    final boardFormFactor = _normalizeSpecString(motherboard.specs?['form_factor']);
    if (boardFormFactor == null) {
      return true;
    }

    final supported = caseComponent.specs?['supported_motherboard_form_factor'] ?? caseComponent.specs?['form_factor'];
    if (supported == null) {
      return true;
    }

    final normalizedSupported = _normalizeSpecString(supported);
    if (normalizedSupported == null) {
      return true;
    }

    return normalizedSupported.contains(boardFormFactor);
  }

  bool _gpuFitsCase(Component? gpu, Component? caseComponent) {
    if (gpu == null || caseComponent == null) {
      return true;
    }

    final gpuLength = _parseNumericSpec(gpu.specs?['length'] ?? gpu.specs?['length_mm']);
    final maxLength = _parseNumericSpec(
      caseComponent.specs?['maximum_video_card_length'] ?? caseComponent.specs?['gpu_max_length'],
    );

    if (gpuLength == null || maxLength == null) {
      return true;
    }

    return gpuLength <= maxLength;
  }

  int? _estimateBuildTdp(Build build) {
    if (build.totalTdp != null && build.totalTdp! > 0) {
      return build.totalTdp;
    }

    var total = 0;
    for (final component in build.components.values) {
      final tdp = _parseNumericSpec(component.specs?['tdp']) ?? _parseNumericSpec(component.specs?['wattage']);
      if (tdp != null) {
        total += tdp;
      }
    }

    return total > 0 ? total : null;
  }

  String? _extractDdrType(Component component) {
    final memoryType = _normalizeSpecString(component.specs?['memory_type'] ?? component.specs?['type']);
    if (memoryType != null && memoryType.contains('DDR')) {
      return memoryType; // Already normalized to upper case and no spaces
    }

    final speed = component.specs?['speed'];
    if (speed is List && speed.isNotEmpty) {
      final first = _normalizeSpecString(speed.first);
      if (first != null && first.contains('DDR')) {
        return first;
      }
    }

    if (speed is String) {
      final normalized = _normalizeSpecString(speed);
      if (normalized != null && normalized.contains('DDR')) {
        return normalized;
      }
    }

    return null;
  }

  String? _normalizeSpecString(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is List && value.isNotEmpty) {
      return _normalizeSpecString(value.first);
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) {
      return null;
    }

    return raw.replaceAll(RegExp('[^A-Za-z0-9]'), '').toUpperCase();
  }

  int? _parseNumericSpec(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      final digits = RegExp(r'\d+').allMatches(value).map((match) => match.group(0)!).join();
      if (digits.isEmpty) {
        return null;
      }
      return int.tryParse(digits);
    }

    if (value is List && value.isNotEmpty) {
      return _parseNumericSpec(value.first);
    }

    return null;
  }
}

  /// Filter components by price range
  List<Component> _filterByPriceRange(List<Component> components) {
    return components.where((component) {
      if (component.priceBdt == null) return true;
      return component.priceBdt! >= _priceRange.start &&
          component.priceBdt! <= _priceRange.end;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final componentState = ref.watch(componentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select ${widget.categoryName}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search ${widget.categoryName}...',
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
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: _performSearch,
            ),
          ),

          // Filter Panel
          if (_showFilters)
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort By
                  Text(
                    'Sort By',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildSortChip('Popular', 'popular'),
                      _buildSortChip('Price: Low to High', 'price_asc'),
                      _buildSortChip('Price: High to Low', 'price_desc'),
                      _buildSortChip('Newest', 'newest'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price Range
                  Text(
                    'Price Range: ৳${_priceRange.start.toInt()} - ৳${_priceRange.end.toInt()}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 100000,
                    divisions: 100,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _resetFilters,
                        child: const Text('Reset'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Apply Filters'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Component List
          Expanded(
            child: _buildComponentList(componentState),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _sortBy = value;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
        fontSize: 13,
      ),
    );
  }

  Widget _buildComponentList(ComponentState state) {
    if (state.isLoading) {
      return _buildLoadingSkeleton();
    }

    if (state.error != null) {
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
                state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: () {
                  ref
                      .read(componentProvider.notifier)
                      .loadComponentsByCategory(widget.category);
                },
              ),
            ],
          ),
        ),
      );
    }

    // Apply compatibility filtering
    final filteredComponents = _getCompatibleComponents(state.components);

    if (filteredComponents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No compatible components found',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                widget.currentBuild != null
                    ? 'No components match your current build configuration'
                    : 'Try different search terms or filters',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Compatibility info banner
        if (widget.currentBuild != null &&
            filteredComponents.length < state.components.length)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  Icons.filter_alt,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Showing ${filteredComponents.length} of ${state.components.length} compatible components',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredComponents.length,
            itemBuilder: (context, index) {
              final component = filteredComponents[index];
              final isSelected = widget.currentComponent?.id == component.id;

              return GestureDetector(
                onTap: () {
                  context.pop(component);
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      context.pop(component);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        ComponentCard(component: component),
                        // Quick Add Button - Positioned at bottom right
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.pop(component);
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              elevation: 4,
                              shadowColor: Colors.black.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Card(
            child: Container(
              height: 120,
              padding: const EdgeInsets.all(16),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 150,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
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
