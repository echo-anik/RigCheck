import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// AppColors removed - using theme
import '../../data/models/component.dart';
import '../../core/utils/toast_utils.dart';

/// Draggable bottom sheet for selecting components
class ComponentSelectionBottomSheet extends ConsumerStatefulWidget {
  final String category;
  final Function(Component) onSelect;
  final List<Component> components;

  const ComponentSelectionBottomSheet({
    super.key,
    required this.category,
    required this.onSelect,
    required this.components,
  });

  @override
  ConsumerState<ComponentSelectionBottomSheet> createState() =>
      _ComponentSelectionBottomSheetState();
}

class _ComponentSelectionBottomSheetState
    extends ConsumerState<ComponentSelectionBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Component> _filteredComponents = [];
  String _sortBy = 'relevance';

  @override
  void initState() {
    super.initState();
    _filteredComponents = widget.components;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterComponents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredComponents = widget.components;
      } else {
        _filteredComponents = widget.components
            .where((component) =>
                component.name.toLowerCase().contains(query.toLowerCase()) ||
                component.brand.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _sortComponents(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      final components = List<Component>.from(_filteredComponents);

      switch (sortBy) {
        case 'price-low':
          components.sort((a, b) =>
              (a.priceBdt ?? 0).compareTo(b.priceBdt ?? 0));
          break;
        case 'price-high':
          components.sort((a, b) =>
              (b.priceBdt ?? 0).compareTo(a.priceBdt ?? 0));
          break;
        case 'name':
          components.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'brand':
          components.sort((a, b) => a.brand.compareTo(b.brand));
          break;
        default:
          // Keep original order for 'relevance'
          break;
      }

      _filteredComponents = components;
    });
  }

  String _getCategoryLabel() {
    final labels = {
      'cpu': 'CPU (Processor)',
      'cpu-cooler': 'CPU Cooler',
      'motherboard': 'Motherboard',
      'memory': 'Memory (RAM)',
      'storage': 'Storage',
      'internal-hard-drive': 'Internal Hard Drive',
      'video-card': 'Graphics Card (GPU)',
      'case': 'PC Case',
      'power-supply': 'Power Supply (PSU)',
    };
    return labels[widget.category] ?? widget.category;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.5, 0.75, 0.95],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select ${_getCategoryLabel()}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_filteredComponents.length} available',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
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
                              _filterComponents('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _filterComponents,
                ),
              ),

              // Sort options
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildSortChip('Relevance', 'relevance'),
                    const SizedBox(width: 8),
                    _buildSortChip('Price: Low to High', 'price-low'),
                    const SizedBox(width: 8),
                    _buildSortChip('Price: High to Low', 'price-high'),
                    const SizedBox(width: 8),
                    _buildSortChip('Name', 'name'),
                    const SizedBox(width: 8),
                    _buildSortChip('Brand', 'brand'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Components list
              Expanded(
                child: _filteredComponents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No components found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredComponents.length,
                        itemBuilder: (context, index) {
                          final component = _filteredComponents[index];
                          return _buildComponentItem(component);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _sortComponents(value);
        }
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildComponentItem(Component component) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          widget.onSelect(component);
          ToastUtils.showSuccess('${component.name} selected');
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Component image placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.computer,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              // Component details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      component.brand,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      component.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (component.priceBdt != null)
                      Text(
                        '৳${component.priceBdt!.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper function to show the component selection bottom sheet
Future<Component?> showComponentSelectionBottomSheet({
  required BuildContext context,
  required String category,
  required List<Component> components,
}) async {
  Component? selectedComponent;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ComponentSelectionBottomSheet(
      category: category,
      components: components,
      onSelect: (component) {
        selectedComponent = component;
      },
    ),
  );

  return selectedComponent;
}
