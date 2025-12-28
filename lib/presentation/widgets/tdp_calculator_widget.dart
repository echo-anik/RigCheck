import 'package:flutter/material.dart';
// AppColors removed - using theme

class TdpCalculatorWidget extends StatelessWidget {
  final int totalTdp;
  final int recommendedPsuWattage;
  final int? selectedPsuWattage;
  final bool showDetails;

  const TdpCalculatorWidget({
    super.key,
    required this.totalTdp,
    required this.recommendedPsuWattage,
    this.selectedPsuWattage,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate PSU status if PSU is selected
    Color psuStatusColor = Theme.of(context).colorScheme.outline;
    String psuStatusText = 'No PSU selected';
    IconData psuStatusIcon = Icons.power_off;
    double? headroomPercentage;

    if (selectedPsuWattage != null) {
      final headroom = selectedPsuWattage! - recommendedPsuWattage;
      headroomPercentage = (headroom / recommendedPsuWattage) * 100;

      if (selectedPsuWattage! < recommendedPsuWattage) {
        psuStatusColor = Theme.of(context).colorScheme.error;
        psuStatusText = 'Insufficient PSU';
        psuStatusIcon = Icons.error;
      } else if (headroomPercentage < 10) {
        psuStatusColor = Colors.orange;
        psuStatusText = 'Minimal headroom';
        psuStatusIcon = Icons.warning_amber;
      } else if (headroomPercentage < 20) {
        psuStatusColor = Colors.orange.withOpacity(0.8);
        psuStatusText = 'Adequate headroom';
        psuStatusIcon = Icons.check_circle_outline;
      } else {
        psuStatusColor = Colors.green;
        psuStatusText = 'Good headroom';
        psuStatusIcon = Icons.check_circle;
      }
    }

    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Power Calculation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // TDP Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total TDP',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${totalTdp}W',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Recommended PSU',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recommendedPsuWattage}W',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (showDetails) ...[
              const SizedBox(height: 16),
              Divider(color: Theme.of(context).colorScheme.surfaceContainerHighest, thickness: 1),
              const SizedBox(height: 16),

              // PSU Status
              if (selectedPsuWattage != null) ...[
                Row(
                  children: [
                    Icon(psuStatusIcon, color: psuStatusColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected PSU: ${selectedPsuWattage}W',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            psuStatusText,
                            style: TextStyle(
                              fontSize: 12,
                              color: psuStatusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // PSU Progress Bar
                _buildPsuProgressBar(
                  context,
                  recommendedPsuWattage.toDouble(),
                  selectedPsuWattage!.toDouble(),
                  psuStatusColor,
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Add a PSU to see power compatibility',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Info Text
              Text(
                'Calculation: (CPU TDP + GPU TDP + 100W) × 1.2',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.outline,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPsuProgressBar(
    BuildContext context,
    double recommended,
    double selected,
    Color statusColor,
  ) {
    final percentage = (recommended / selected).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Power usage',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${recommended.toStringAsFixed(0)}W needed',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            Text(
              '${(selected - recommended).toStringAsFixed(0)}W headroom',
              style: TextStyle(
                fontSize: 11,
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Compact version for inline display
class CompactTdpDisplay extends StatelessWidget {
  final int totalTdp;
  final int recommendedPsuWattage;

  const CompactTdpDisplay({
    super.key,
    required this.totalTdp,
    required this.recommendedPsuWattage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flash_on, color: Theme.of(context).colorScheme.secondary, size: 16),
          const SizedBox(width: 8),
          Text(
            '${totalTdp}W TDP',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.power, color: Theme.of(context).colorScheme.primary, size: 16),
          const SizedBox(width: 8),
          Text(
            '${recommendedPsuWattage}W PSU',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
