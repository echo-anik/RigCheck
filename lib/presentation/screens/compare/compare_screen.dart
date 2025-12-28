import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
// AppColors removed - using theme
import '../../../core/services/comparison_service.dart';
import '../../../data/models/component.dart';
import '../../widgets/comparison_table.dart';
import '../../widgets/comparison_selector.dart';
import '../../widgets/shimmer_loading.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  int? _selectedSlotIndex;
  bool _showUSD = false;
  static const double usdToBdtRate = 120.0;

  @override
  Widget build(BuildContext context) {
    final componentsAsync = ref.watch(comparisonComponentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Components'),
        actions: [
          // Clear all button
          componentsAsync.whenData((components) {
            if (components.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Clear all',
                onPressed: () => _showClearConfirmation(context),
              );
            }
            return const SizedBox.shrink();
          }).value ?? const SizedBox.shrink(),
        ],
      ),
      body: componentsAsync.when(
        data: (components) => _buildContent(context, components),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load comparison',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Component> components) {
    // Ensure we always have at least 2 slots
    final displaySlots = List<Component?>.filled(
      components.length < 2 ? 2 : components.length,
      null,
    );

    for (int i = 0; i < components.length; i++) {
      displaySlots[i] = components[i];
    }

    final canAddMore = components.length < ComparisonService.maxComparisonItems;
    final category = components.isNotEmpty ? components.first.category : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          if (components.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Getting Started',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a component category and add items to compare their specifications side by side. You can compare up to 4 components of the same type.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

          // Category indicator
          if (category != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Comparing:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(_getCategoryLabel(category)),
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Component slots
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Determine grid columns based on screen width
                final crossAxisCount = constraints.maxWidth > 900
                    ? 4
                    : constraints.maxWidth > 600
                        ? 3
                        : 2;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: displaySlots.length + (canAddMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < displaySlots.length) {
                      return _buildComponentSlot(
                        context,
                        displaySlots[index],
                        index,
                      );
                    } else {
                      return _buildAddSlotButton(context);
                    }
                  },
                );
              },
            ),
          ),

          // Currency toggle
          if (components.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showUSD = !_showUSD;
                      });
                    },
                    icon: const Icon(Icons.currency_exchange, size: 18),
                    label: Text(_showUSD ? 'Show BDT' : 'Show USD'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

          // Comparison table
          if (components.length >= 2)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ComparisonTable(
                components: components,
                showUSD: _showUSD,
              ),
            )
          else if (components.length == 1)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.compare_arrows,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Add More Components',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add at least one more component to see the comparison table',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComponentSlot(
    BuildContext context,
    Component? component,
    int index,
  ) {
    if (component == null) {
      return _buildEmptySlot(context, index);
    }

    final price = component.priceBdt;
    final priceText = price != null
        ? (_showUSD
            ? '\$${(price / usdToBdtRate).toStringAsFixed(2)}'
            : '৳${price.toStringAsFixed(0)}')
        : 'N/A';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with remove button
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Component ${index + 1}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => _removeComponent(component),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Remove',
                ),
              ],
            ),
          ),

          // Image
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: component.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: component.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.computer,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand
                Text(
                  component.brand,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Name
                Text(
                  component.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Price
                Text(
                  priceText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySlot(BuildContext context, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _openComponentSelector(index),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Component',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddSlotButton(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: InkWell(
        onTap: () => _addSlot(),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_box_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Add Another',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Up to 4 items',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _openComponentSelector(int slotIndex) {
    setState(() {
      _selectedSlotIndex = slotIndex;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ComparisonSelector(
        onComponentSelected: (component) {
          _addComponent(component);
          Navigator.pop(context);
        },
      ),
    ).then((_) {
      setState(() {
        _selectedSlotIndex = null;
      });
    });
  }

  Future<void> _addComponent(Component component) async {
    final service = ref.read(comparisonServiceProvider);
    final success = await service.addToComparison(component);

    if (!success && mounted) {
      final category = await service.getComparisonCategory();
      final count = await service.getComparisonCount();

      String message;
      if (count >= ComparisonService.maxComparisonItems) {
        message = 'Maximum 4 components can be compared';
      } else if (category != null && category != component.category) {
        message = 'Can only compare components of the same type';
      } else {
        message = 'Component is already in comparison';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else if (mounted) {
      // Refresh the list
      ref.invalidate(comparisonComponentsProvider);
    }
  }

  Future<void> _removeComponent(Component component) async {
    final service = ref.read(comparisonServiceProvider);
    await service.removeFromComparison(component.productId);

    if (mounted) {
      ref.invalidate(comparisonComponentsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Component removed from comparison'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _addSlot() async {
    final components = await ref.read(comparisonComponentsProvider.future);
    if (components.length < ComparisonService.maxComparisonItems) {
      _openComponentSelector(components.length);
    }
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Comparison'),
        content: const Text(
          'Are you sure you want to remove all components from comparison?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final service = ref.read(comparisonServiceProvider);
              await service.clearComparison();
              if (mounted) {
                ref.invalidate(comparisonComponentsProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Comparison cleared'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text(
              'Clear',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(String category) {
    const categoryLabels = {
      'cpu': 'Processors (CPU)',
      'video_card': 'Graphics Cards (GPU)',
      'video-card': 'Graphics Cards (GPU)',
      'motherboard': 'Motherboards',
      'memory': 'Memory (RAM)',
      'internal_hard_drive': 'Storage Drives',
      'internal-hard-drive': 'Storage Drives',
      'power_supply': 'Power Supplies',
      'power-supply': 'Power Supplies',
      'case': 'Cases',
      'cpu_cooler': 'CPU Coolers',
      'cpu-cooler': 'CPU Coolers',
    };

    return categoryLabels[category.toLowerCase()] ?? category;
  }
}
