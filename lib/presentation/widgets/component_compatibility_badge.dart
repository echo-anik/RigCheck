import 'package:flutter/material.dart';
// AppColors removed - using theme

/// Badge to show compatibility status on component cards
class ComponentCompatibilityBadge extends StatelessWidget {
  final bool isCompatible;
  final String? reason;
  final bool showText;

  const ComponentCompatibilityBadge({
    super.key,
    required this.isCompatible,
    this.reason,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompatible ? Colors.green : Theme.of(context).colorScheme.error;
    final icon = isCompatible ? Icons.check_circle : Icons.cancel;
    final text = isCompatible ? 'Compatible' : 'Incompatible';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          if (showText) ...[
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Badge for partial compatibility (warnings)
class CompatibilityWarningBadge extends StatelessWidget {
  final String message;
  final bool showIcon;

  const CompatibilityWarningBadge({
    super.key,
    required this.message,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(Icons.warning_amber, size: 14, color: Colors.orange),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Overlay badge that can be positioned on top of component cards
class CompatibilityOverlayBadge extends StatelessWidget {
  final bool isCompatible;
  final bool hasWarning;
  final VoidCallback? onTap;

  const CompatibilityOverlayBadge({
    super.key,
    required this.isCompatible,
    this.hasWarning = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    IconData icon;

    if (!isCompatible) {
      backgroundColor = Theme.of(context).colorScheme.error;
      icon = Icons.cancel;
    } else if (hasWarning) {
      backgroundColor = Colors.orange;
      icon = Icons.warning_amber;
    } else {
      backgroundColor = Colors.green;
      icon = Icons.check_circle;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}

/// Detailed compatibility indicator with reason
class DetailedCompatibilityIndicator extends StatelessWidget {
  final bool isCompatible;
  final String? reason;
  final List<String>? issues;

  const DetailedCompatibilityIndicator({
    super.key,
    required this.isCompatible,
    this.reason,
    this.issues,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompatible ? Colors.green : Theme.of(context).colorScheme.error;
    final icon = isCompatible ? Icons.check_circle : Icons.error;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isCompatible ? 'Compatible' : 'Not Compatible',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (reason != null) ...[
            const SizedBox(height: 8),
            Text(
              reason!,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.9),
              ),
            ),
          ],
          if (issues != null && issues!.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...issues!.map((issue) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.arrow_right,
                        size: 16,
                        color: color.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          issue,
                          style: TextStyle(
                            fontSize: 11,
                            color: color.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

/// Simple icon-only compatibility indicator
class IconCompatibilityIndicator extends StatelessWidget {
  final bool isCompatible;
  final double size;

  const IconCompatibilityIndicator({
    super.key,
    required this.isCompatible,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      isCompatible ? Icons.check_circle : Icons.cancel,
      color: isCompatible ? Colors.green : Theme.of(context).colorScheme.error,
      size: size,
    );
  }
}
