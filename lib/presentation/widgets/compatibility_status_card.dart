import 'package:flutter/material.dart';
// AppColors removed - using theme
import '../../core/services/compatibility_service.dart';

class CompatibilityStatusCard extends StatelessWidget {
  final LocalCompatibilityResult? compatibilityResult;
  final VoidCallback? onViewDetails;

  const CompatibilityStatusCard({
    super.key,
    this.compatibilityResult,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (compatibilityResult == null) {
      return const SizedBox.shrink();
    }

    final hasErrors = compatibilityResult!.hasErrors;
    final hasWarnings = compatibilityResult!.hasWarnings;
    final isValid = compatibilityResult!.isValid && !hasWarnings;

    Color statusColor;
    IconData statusIcon;
    String statusTitle;
    String statusMessage;

    if (hasErrors) {
      statusColor = Theme.of(context).colorScheme.error;
      statusIcon = Icons.cancel;
      statusTitle = 'Incompatible Build';
      statusMessage = '${compatibilityResult!.errors.length} critical issue${compatibilityResult!.errors.length > 1 ? 's' : ''} found';
    } else if (hasWarnings) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning_amber_rounded;
      statusTitle = 'Build with Warnings';
      statusMessage = '${compatibilityResult!.warnings.length} warning${compatibilityResult!.warnings.length > 1 ? 's' : ''} detected';
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusTitle = 'All Compatible';
      statusMessage = 'No compatibility issues detected';
    }

    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      color: statusColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusMessage,
                      style: TextStyle(
                        fontSize: 13,
                        color: statusColor.withOpacity(0.8),
                      ),
                    ),
                    if (hasErrors && hasWarnings) ...[
                      const SizedBox(height: 4),
                      Text(
                        '+ ${compatibilityResult!.warnings.length} warning${compatibilityResult!.warnings.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onViewDetails != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: statusColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact version for smaller spaces
class CompactCompatibilityIndicator extends StatelessWidget {
  final LocalCompatibilityResult? compatibilityResult;

  const CompactCompatibilityIndicator({
    super.key,
    this.compatibilityResult,
  });

  @override
  Widget build(BuildContext context) {
    if (compatibilityResult == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.help_outline, size: 14, color: Colors.grey),
            SizedBox(width: 4),
            Text(
              'Not checked',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final hasErrors = compatibilityResult!.hasErrors;
    final hasWarnings = compatibilityResult!.hasWarnings;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (hasErrors) {
      statusColor = Theme.of(context).colorScheme.error;
      statusIcon = Icons.cancel;
      statusText = 'Error';
    } else if (hasWarnings) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning_amber;
      statusText = 'Warning';
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'OK';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
