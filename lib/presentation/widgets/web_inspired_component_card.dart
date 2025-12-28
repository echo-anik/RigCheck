import 'package:flutter/material.dart';
import '../../data/models/component.dart';
import '../../core/theme/web_inspired_theme.dart';

/// Web-inspired component card matching rigcheck-web design
class WebInspiredComponentCard extends StatelessWidget {
  final Component component;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorited;

  const WebInspiredComponentCard({
    super.key,
    required this.component,
    this.onTap,
    this.onFavorite,
    this.isFavorited = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              height: 180,
              width: double.infinity,
              color: WebInspiredTheme.mutedColor.withOpacity(0.3),
              child: Stack(
                children: [
                  // Component Image
                  if (component.imageUrl != null && component.imageUrl!.isNotEmpty)
                    Image.network(
                      component.imageUrl!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                    )
                  else
                    _buildImagePlaceholder(),
                  
                  // Favorite Button
                  if (onFavorite != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(WebInspiredTheme.radiusSm),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            isFavorited ? Icons.favorite : Icons.favorite_border,
                            color: isFavorited ? Colors.red : WebInspiredTheme.mutedForeground,
                          ),
                          iconSize: 20,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          onPressed: onFavorite,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(WebInspiredTheme.radiusSm),
                    ),
                    child: Text(
                      component.category.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Product Name
                  Text(
                    component.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Brand
                  Text(
                    component.brand,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: WebInspiredTheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Key Specs (first 2 specs)
                  if (component.specs != null && component.specs!.isNotEmpty)
                    _buildKeySpecs(context, component.specs!),
                  
                  const SizedBox(height: 12),
                  
                  // Price and Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Expanded(
                        child: Text(
                          component.priceBdt != null
                              ? '৳${component.priceBdt!.toStringAsFixed(0)}'
                              : 'Price N/A',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      
                      // View Button
                      OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('View'),
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
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        _getCategoryIcon(component.category),
        size: 64,
        color: WebInspiredTheme.mutedForeground.withOpacity(0.3),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'cpu':
        return Icons.memory;
      case 'gpu':
      case 'video-card':
        return Icons.videogame_asset;
      case 'motherboard':
        return Icons.developer_board;
      case 'ram':
      case 'memory':
        return Icons.sd_storage;
      case 'storage':
      case 'internal-hard-drive':
        return Icons.storage;
      case 'psu':
      case 'power-supply':
        return Icons.power;
      case 'case':
        return Icons.computer;
      case 'cooler':
      case 'cpu-cooler':
        return Icons.ac_unit;
      default:
        return Icons.hardware;
    }
  }

  Widget _buildKeySpecs(BuildContext context, Map<String, dynamic> specs) {
    final theme = Theme.of(context);
    final entries = specs.entries.take(2).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: WebInspiredTheme.mutedForeground,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_formatSpecKey(entry.key)}: ${entry.value}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: WebInspiredTheme.mutedForeground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatSpecKey(String key) {
    // Convert snake_case to Title Case
    return key
        .split('_')
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
