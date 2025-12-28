import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// AppColors removed - using theme
import '../../core/utils/toast_utils.dart';

/// Advanced filter options for component search
class AdvancedSearchFilters {
  final double? minPrice;
  final double? maxPrice;
  final List<String> brands;
  final List<String> categories;
  final String? availability;
  final String? sortBy;

  AdvancedSearchFilters({
    this.minPrice,
    this.maxPrice,
    this.brands = const [],
    this.categories = const [],
    this.availability,
    this.sortBy = 'relevance',
  });

  AdvancedSearchFilters copyWith({
    double? minPrice,
    double? maxPrice,
    List<String>? brands,
    List<String>? categories,
    String? availability,
    String? sortBy,
  }) {
    return AdvancedSearchFilters(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      brands: brands ?? this.brands,
      categories: categories ?? this.categories,
      availability: availability ?? this.availability,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters {
    return minPrice != null ||
        maxPrice != null ||
        brands.isNotEmpty ||
        categories.isNotEmpty ||
        availability != null ||
        sortBy != 'relevance';
  }
}

/// Provider for search filters
final searchFiltersProvider = StateProvider<AdvancedSearchFilters>((ref) {
  return AdvancedSearchFilters();
});

/// Filter bottom sheet widget
class AdvancedFiltersBottomSheet extends ConsumerStatefulWidget {
  final AdvancedSearchFilters currentFilters;
  final Function(AdvancedSearchFilters) onApply;

  const AdvancedFiltersBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onApply,
  });

  @override
  ConsumerState<AdvancedFiltersBottomSheet> createState() =>
      _AdvancedFiltersBottomSheetState();
}

class _AdvancedFiltersBottomSheetState
    extends ConsumerState<AdvancedFiltersBottomSheet> {
  late double _minPrice;
  late double _maxPrice;
  late List<String> _selectedBrands;
  late List<String> _selectedCategories;
  late String? _availability;
  late String _sortBy;

  // Available options
  final List<String> _availableBrands = [
    'ASUS',
    'MSI',
    'Gigabyte',
    'NVIDIA',
    'AMD',
    'Intel',
    'Corsair',
    'Kingston',
    'Samsung',
    'Western Digital',
  ];

  final List<String> _availableCategories = [
    'CPU',
    'GPU',
    'Motherboard',
    'Memory',
    'Storage',
    'PSU',
    'Case',
    'Cooling',
  ];

  final List<String> _sortOptions = [
    'relevance',
    'price-low',
    'price-high',
    'rating',
    'newest',
  ];

  @override
  void initState() {
    super.initState();
    _minPrice = widget.currentFilters.minPrice ?? 0;
    _maxPrice = widget.currentFilters.maxPrice ?? 500000;
    _selectedBrands = List.from(widget.currentFilters.brands);
    _selectedCategories = List.from(widget.currentFilters.categories);
    _availability = widget.currentFilters.availability;
    _sortBy = widget.currentFilters.sortBy ?? 'relevance';
  }

  void _resetFilters() {
    setState(() {
      _minPrice = 0;
      _maxPrice = 500000;
      _selectedBrands.clear();
      _selectedCategories.clear();
      _availability = null;
      _sortBy = 'relevance';
    });
  }

  void _applyFilters() {
    final filters = AdvancedSearchFilters(
      minPrice: _minPrice > 0 ? _minPrice : null,
      maxPrice: _maxPrice < 500000 ? _maxPrice : null,
      brands: _selectedBrands,
      categories: _selectedCategories,
      availability: _availability,
      sortBy: _sortBy,
    );
    widget.onApply(filters);
    ToastUtils.showSuccess('Filters applied');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _resetFilters,
                      child: const Text('Reset'),
                    ),
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: _applyFilters,
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),

              // Filters content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Price Range
                    _buildSectionTitle('Price Range (৳)'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          '৳${_minPrice.toInt()}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Expanded(
                          child: RangeSlider(
                            values: RangeValues(_minPrice, _maxPrice),
                            min: 0,
                            max: 500000,
                            divisions: 100,
                            activeColor: Theme.of(context).colorScheme.primary,
                            onChanged: (values) {
                              setState(() {
                                _minPrice = values.start;
                                _maxPrice = values.end;
                              });
                            },
                          ),
                        ),
                        Text(
                          '৳${_maxPrice.toInt()}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Brands
                    _buildSectionTitle('Brands'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableBrands.map((brand) {
                        final isSelected = _selectedBrands.contains(brand);
                        return FilterChip(
                          label: Text(brand),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedBrands.add(brand);
                              } else {
                                _selectedBrands.remove(brand);
                              }
                            });
                          },
                          selectedColor: Theme.of(context).colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Categories
                    _buildSectionTitle('Categories'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableCategories.map((category) {
                        final isSelected =
                            _selectedCategories.contains(category);
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategories.add(category);
                              } else {
                                _selectedCategories.remove(category);
                              }
                            });
                          },
                          selectedColor: Theme.of(context).colorScheme.secondary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Sort By
                    _buildSectionTitle('Sort By'),
                    const SizedBox(height: 12),
                    ...(_sortOptions.map((option) {
                      return RadioListTile<String>(
                        title: Text(_formatSortLabel(option)),
                        value: option,
                        groupValue: _sortBy,
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value!;
                          });
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      );
                    })),
                    const SizedBox(height: 24),

                    // Availability
                    _buildSectionTitle('Availability'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: _availability == null,
                          onSelected: (selected) {
                            setState(() {
                              _availability = null;
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('In Stock'),
                          selected: _availability == 'in_stock',
                          onSelected: (selected) {
                            setState(() {
                              _availability = selected ? 'in_stock' : null;
                            });
                          },
                          selectedColor: Colors.green,
                        ),
                        ChoiceChip(
                          label: const Text('Pre-order'),
                          selected: _availability == 'preorder',
                          onSelected: (selected) {
                            setState(() {
                              _availability = selected ? 'preorder' : null;
                            });
                          },
                          selectedColor: Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  String _formatSortLabel(String sortOption) {
    final labels = {
      'relevance': 'Relevance',
      'price-low': 'Price: Low to High',
      'price-high': 'Price: High to Low',
      'rating': 'Rating',
      'newest': 'Newest First',
    };
    return labels[sortOption] ?? sortOption;
  }
}
