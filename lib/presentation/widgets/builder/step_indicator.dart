import 'package:flutter/material.dart';
// AppColors removed - using theme

/// Model for a build step
class BuildStepModel {
  final String id;
  final String category;
  final String label;
  final String description;
  final bool required;
  final IconData icon;

  const BuildStepModel({
    required this.id,
    required this.category,
    required this.label,
    required this.description,
    required this.required,
    required this.icon,
  });
}

/// Pre-defined build steps following the web version order
const List<BuildStepModel> buildSteps = [
  BuildStepModel(
    id: 'cpu',
    category: 'cpu',
    label: 'Processor',
    description: 'The brain of your PC - choose based on your performance needs',
    required: true,
    icon: Icons.memory,
  ),
  BuildStepModel(
    id: 'motherboard',
    category: 'motherboard',
    label: 'Motherboard',
    description: 'Must match your CPU socket and support your components',
    required: true,
    icon: Icons.developer_board,
  ),
  BuildStepModel(
    id: 'memory',
    category: 'memory',
    label: 'RAM (Memory)',
    description: 'Choose capacity and speed compatible with your motherboard',
    required: true,
    icon: Icons.sd_storage,
  ),
  BuildStepModel(
    id: 'video-card',
    category: 'video-card',
    label: 'Graphics Card',
    description: 'Essential for gaming and content creation',
    required: false,
    icon: Icons.videogame_asset,
  ),
  BuildStepModel(
    id: 'internal-hard-drive',
    category: 'internal-hard-drive',
    label: 'Storage',
    description: 'SSD recommended for OS, add HDD for mass storage',
    required: true,
    icon: Icons.storage,
  ),
  BuildStepModel(
    id: 'power-supply',
    category: 'power-supply',
    label: 'Power Supply',
    description: 'Ensure sufficient wattage for all components',
    required: true,
    icon: Icons.power,
  ),
  BuildStepModel(
    id: 'case',
    category: 'case',
    label: 'Case',
    description: 'Pick a size that fits your motherboard and GPU',
    required: false,
    icon: Icons.computer,
  ),
  BuildStepModel(
    id: 'cpu-cooler',
    category: 'cpu-cooler',
    label: 'CPU Cooler',
    description: 'Better cooling for overclocking and quieter operation',
    required: false,
    icon: Icons.ac_unit,
  ),
];

/// Widget that displays step indicators in a grid
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final Set<String> completedSteps;
  final Function(int) onStepTap;
  final bool Function(int index)? isStepEnabled;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.completedSteps,
    required this.onStepTap,
    this.isStepEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate grid columns based on screen width
        final crossAxisCount = constraints.maxWidth < 600 ? 4 : 8;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.85,
          ),
          itemCount: buildSteps.length,
          itemBuilder: (context, index) {
            final step = buildSteps[index];
            final isCompleted = completedSteps.contains(step.category);
            final isCurrent = index == currentStep;
            final enabled = isStepEnabled?.call(index) ?? true;

            return _StepIndicatorItem(
              step: step,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isEnabled: enabled,
              onTap: () => onStepTap(index),
            );
          },
        );
      },
    );
  }
}

class _StepIndicatorItem extends StatelessWidget {
  final BuildStepModel step;
  final bool isCompleted;
  final bool isCurrent;
  final bool isEnabled;
  final VoidCallback onTap;

  const _StepIndicatorItem({
    required this.step,
    required this.isCompleted,
    required this.isCurrent,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color backgroundColor;
    Color iconColor;

    if (!isEnabled) {
      borderColor = Colors.grey.shade300;
      backgroundColor = Colors.transparent;
      iconColor = Colors.grey.shade400;
    } else if (isCurrent) {
      borderColor = Theme.of(context).colorScheme.primary;
      backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
      iconColor = Theme.of(context).colorScheme.primary;
    } else if (isCompleted) {
      borderColor = Colors.green;
      backgroundColor = Colors.green.withOpacity(0.05);
      iconColor = Colors.green;
    } else {
      borderColor = Colors.grey.shade300;
      backgroundColor = Colors.transparent;
      iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: isCurrent ? 2.5 : 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              step.icon,
              size: 28,
              color: iconColor,
            ),
            const SizedBox(height: 6),
            Text(
              step.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                color: isEnabled
                    ? (isCurrent
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurfaceVariant)
                    : Colors.grey.shade500,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            if (isCompleted) ...[
              const SizedBox(height: 4),
              Icon(
                Icons.check_circle,
                size: 14,
                color: Colors.green,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
