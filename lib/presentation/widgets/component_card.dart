import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// AppColors removed - using theme
import '../../data/models/component.dart';
import '../screens/components/component_detail_screen.dart';
import '../screens/builder/builder_screen.dart';
import '../providers/favorites_provider.dart';
import '../providers/active_build_provider.dart';
import '../../core/services/comparison_service.dart';

class ComponentCard extends ConsumerWidget {
  final Component component;
  final bool showFavoriteButton;
  final bool showAddToBuildButton;
  final bool showAddToCompareButton;
  final VoidCallback? onTap;

  const ComponentCard({
    super.key,
    required this.component,
    this.showFavoriteButton = true,
    this.showAddToBuildButton = true,
    this.showAddToCompareButton = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteStatusAsync = ref.watch(componentFavoriteStatusProvider(component.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap ?? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ComponentDetailScreen(component: component),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Component Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: component.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: component.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.computer,
                          color: Theme.of(context).colorScheme.outline,
                          size: 40,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // Component Details
              Expanded(
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
                    ),
                    const SizedBox(height: 4),
                    // Name
                    Text(
                      component.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Specs
                    if (component.specs != null) ...[
                      _buildSpecsRow(context),
                      const SizedBox(height: 8),
                    ],
                    // Price and Availability
                    Row(
                      children: [
                        // Price
                        if (component.priceBdt != null)
                          Text(
                            '\$${(component.priceBdt! / 120).toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          )
                        else
                          Text(
                            'Price N/A',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        const SizedBox(width: 8),
                        _buildAvailabilityBadge(context),
                      ],
                    ),
                    // Action Buttons Row
                    if (showAddToBuildButton || showAddToCompareButton)
                      const SizedBox(height: 8),
                    if (showAddToBuildButton || showAddToCompareButton)
                      Row(
                        children: [
                          // Add to Build Button
                          if (showAddToBuildButton)
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {
                                  final activeBuildState = ref.read(activeBuildProvider);
                                  if (activeBuildState.hasActiveBuild) {
                                    // Add to existing build
                                    ref.read(activeBuildProvider.notifier).addComponent(
                                      component.category,
                                      component,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Added ${component.name} to active build'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  } else {
                                    // Start new build
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BuilderScreen(
                                          initialComponent: component,
                                          initialCategory: component.category,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.add_circle_outline, size: 16),
                                label: const Text('Add to Build', style: TextStyle(fontSize: 12)),
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                          // Add to Compare Button
                          if (showAddToCompareButton)
                            Expanded(
                              child: _buildAddToCompareButton(context, ref),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              // Favorite Button
              if (showFavoriteButton)
                favoriteStatusAsync.when(
                  data: (isFavorited) => IconButton(
                    icon: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: isFavorited ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () async {
                      final notifier = ref.read(favoritesProvider.notifier);
                      final success = await notifier.toggleComponentFavorite(component);

                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFavorited
                                  ? 'Failed to remove from favorites'
                                  : 'Failed to add to favorites',
                            ),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                    },
                    tooltip: isFavorited ? 'Remove from favorites' : 'Add to favorites',
                  ),
                  loading: () => const SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  error: (_, __) => IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: null,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecsRow(BuildContext context) {
    final specs = component.specs!;
    final displaySpecs = <String>[];

    // Add category-specific specs
    switch (component.category) {
      case 'cpu':
        if (specs['core_count'] != null) {
          displaySpecs.add('${specs['core_count']} cores');
        }
        if (specs['core_clock'] != null) {
          displaySpecs.add('${specs['core_clock']}GHz');
        }
        break;
      case 'video-card':
        if (specs['memory'] != null) {
          displaySpecs.add('${specs['memory']}GB');
        }
        if (specs['chipset'] != null) {
          displaySpecs.add(specs['chipset']);
        }
        break;
      case 'memory':
        if (specs['speed'] != null && specs['speed'] is List) {
          final speedList = specs['speed'] as List;
          if (speedList.length > 1) {
            displaySpecs.add('DDR${speedList[0]} ${speedList[1]}MHz');
          }
        }
        break;
      default:
        // Add first 2 specs if available
        final keys = specs.keys.take(2);
        for (var key in keys) {
          if (specs[key] != null) {
            displaySpecs.add('${specs[key]}');
          }
        }
    }

    if (displaySpecs.isEmpty) return const SizedBox.shrink();

    return Text(
      displaySpecs.join(' • '),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAvailabilityBadge(BuildContext context) {
    final status = component.availabilityStatus ?? 'in_stock';
    Color badgeColor;
    String badgeText;

    switch (status.toLowerCase()) {
      case 'in_stock':
        badgeColor = Colors.green;
        badgeText = 'In Stock';
        break;
      case 'out_of_stock':
        badgeColor = Theme.of(context).colorScheme.error;
        badgeText = 'Out of Stock';
        break;
      case 'limited':
        badgeColor = Colors.orange;
        badgeText = 'Limited';
        break;
      default:
        badgeColor = Theme.of(context).colorScheme.onSurfaceVariant;
        badgeText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        badgeText,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
      ),
    );
  }

  Widget _buildAddToCompareButton(BuildContext context, WidgetRef ref) {
    final isInComparisonAsync = ref.watch(isInComparisonProvider(component.productId));

    return isInComparisonAsync.when(
      data: (isInComparison) => TextButton.icon(
        onPressed: isInComparison
            ? () {
                // Navigate to compare screen
                context.push('/compare');
              }
            : () async {
                final service = ref.read(comparisonServiceProvider);
                final success = await service.addToComparison(component);

                if (success && context.mounted) {
                  // Invalidate providers to update UI
                  ref.invalidate(isInComparisonProvider(component.productId));
                  ref.invalidate(comparisonCountProvider);
                  ref.invalidate(comparisonComponentsProvider);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Added to comparison'),
                      backgroundColor: Colors.green,
                      action: SnackBarAction(
                        label: 'View',
                        textColor: Colors.white,
                        onPressed: () {
                          context.push('/compare');
                        },
                      ),
                    ),
                  );
                } else if (!success && context.mounted) {
                  final category = await service.getComparisonCategory();
                  final count = await service.getComparisonCount();

                  String message;
                  if (count >= ComparisonService.maxComparisonItems) {
                    message = 'Maximum 4 components can be compared';
                  } else if (category != null && category != component.category) {
                    message = 'Can only compare components of the same type';
                  } else {
                    message = 'Failed to add to comparison';
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
        icon: Icon(
          isInComparison ? Icons.compare_arrows : Icons.compare_outlined,
          size: 16,
        ),
        label: Text(
          isInComparison ? 'In Compare' : 'Compare',
          style: const TextStyle(fontSize: 12),
        ),
        style: TextButton.styleFrom(
          foregroundColor: isInComparison ? Colors.green : Theme.of(context).colorScheme.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      loading: () => const SizedBox(
        height: 32,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => TextButton.icon(
        onPressed: null,
        icon: const Icon(Icons.compare_outlined, size: 16),
        label: const Text('Compare', style: TextStyle(fontSize: 12)),
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
