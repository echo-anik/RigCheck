import 'package:flutter/material.dart';
// AppColors removed - using theme
import '../../data/models/build_template.dart';

/// Widget for displaying a build template card
class TemplateCard extends StatelessWidget {
  final BuildTemplate template;
  final VoidCallback onTap;
  final bool isSelected;

  const TemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: Colors.blue, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.1),
                      Colors.blue.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(template.category)
                          .withOpacity(isDark ? 0.3 : 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        template.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(template.category)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            template.category.displayName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getCategoryColor(template.category),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Colors.blue,
                      size: 28,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                template.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                  fontSize: 13,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Budget
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        template.budget,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Specs summary
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (template.targetSpecs.cpuCores != null)
                    _buildSpecChip(
                      Icons.memory,
                      '${template.targetSpecs.cpuCores} Cores',
                      theme,
                    ),
                  if (template.targetSpecs.ramCapacityGB != null)
                    _buildSpecChip(
                      Icons.sd_storage,
                      '${template.targetSpecs.ramCapacityGB}GB RAM',
                      theme,
                    ),
                  if (template.targetSpecs.gpuTier != null)
                    _buildSpecChip(
                      Icons.videogame_asset,
                      _getGpuTierDisplay(template.targetSpecs.gpuTier!),
                      theme,
                    ),
                  if (template.targetSpecs.storageGB != null)
                    _buildSpecChip(
                      Icons.storage,
                      '${template.targetSpecs.storageGB}GB',
                      theme,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecChip(IconData icon, String label, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.blue),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(BuildTemplateCategory category) {
    switch (category) {
      case BuildTemplateCategory.gaming:
        return Colors.blue;
      case BuildTemplateCategory.enthusiast:
        return Colors.deepPurple;
      case BuildTemplateCategory.workstation:
        return Colors.orange;
      case BuildTemplateCategory.office:
        return Colors.blue;
      case BuildTemplateCategory.budget:
        return Colors.green;
    }
  }

  String _getGpuTierDisplay(GpuTier tier) {
    switch (tier) {
      case GpuTier.ultra:
        return 'Ultra GPU';
      case GpuTier.high:
        return 'High GPU';
      case GpuTier.mid:
        return 'Mid GPU';
      case GpuTier.entry:
        return 'Entry GPU';
    }
  }
}
