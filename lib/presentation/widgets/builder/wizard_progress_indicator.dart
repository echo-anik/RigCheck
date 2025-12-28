import 'package:flutter/material.dart';
// AppColors removed - using theme

/// Widget that displays a progress bar showing wizard completion
class WizardProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final int? completedCount; // Optional: number of components selected

  const WizardProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = ((currentStep + 1) / totalSteps);
    final percentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step ${currentStep + 1} of $totalSteps',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (completedCount != null && completedCount! > 0)
                    Text(
                      '$completedCount component${completedCount! != 1 ? 's' : ''} selected',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              Text(
                '$percentage% Complete',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
