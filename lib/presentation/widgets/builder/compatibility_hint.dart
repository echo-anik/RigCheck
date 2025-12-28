import 'package:flutter/material.dart';
// AppColors removed - using theme

/// Widget that displays compatibility hints for component selection
class CompatibilityHint extends StatelessWidget {
  final String? message;
  final CompatibilityHintType type;

  const CompatibilityHint({
    super.key,
    this.message,
    this.type = CompatibilityHintType.info,
  });

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }

    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    IconData icon;

    switch (type) {
      case CompatibilityHintType.info:
        backgroundColor = Colors.blue.withOpacity(0.1);
        borderColor = Colors.blue.withOpacity(0.3);
        iconColor = Colors.blue;
        icon = Icons.info_outline;
        break;
      case CompatibilityHintType.warning:
        backgroundColor = Colors.orange.withOpacity(0.1);
        borderColor = Colors.orange.withOpacity(0.3);
        iconColor = Colors.orange;
        icon = Icons.warning_amber_outlined;
        break;
      case CompatibilityHintType.success:
        backgroundColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green.withOpacity(0.3);
        iconColor = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case CompatibilityHintType.error:
        backgroundColor = Theme.of(context).colorScheme.error.withOpacity(0.1);
        borderColor = Theme.of(context).colorScheme.error.withOpacity(0.3);
        iconColor = Theme.of(context).colorScheme.error;
        icon = Icons.error_outline;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message!,
              style: TextStyle(
                fontSize: 13,
                color: iconColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Type of compatibility hint
enum CompatibilityHintType {
  info,
  warning,
  success,
  error,
}

/// Widget that displays a compact compatibility status during checking
class CompatibilityCheckingIndicator extends StatelessWidget {
  final bool isChecking;
  final String? message;

  const CompatibilityCheckingIndicator({
    super.key,
    this.isChecking = false,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (!isChecking) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message ?? 'Checking compatibility...',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper class to generate compatibility hints based on selected components
class CompatibilityHintGenerator {
  /// Generate hint for motherboard selection based on CPU
  static String? getMotherboardHint(Map<String, dynamic>? cpuSpecs) {
    if (cpuSpecs == null || cpuSpecs['socket'] == null) {
      return 'Select a CPU first to see compatible motherboards';
    }

    final socket = cpuSpecs['socket'];
    return 'Showing motherboards with $socket socket compatible with your CPU';
  }

  /// Generate hint for RAM selection based on motherboard
  static String? getMemoryHint(Map<String, dynamic>? motherboardSpecs) {
    if (motherboardSpecs == null) {
      return 'Select a motherboard first to see compatible RAM';
    }

    final memoryType = motherboardSpecs['memory_type'];
    final memorySlots = motherboardSpecs['memory_slots'];

    if (memoryType != null && memorySlots != null) {
      return 'Your motherboard supports $memoryType with $memorySlots slots';
    } else if (memoryType != null) {
      return 'Your motherboard supports $memoryType memory';
    }

    return null;
  }

  /// Generate hint for GPU selection based on case and motherboard
  static String? getGpuHint(
    Map<String, dynamic>? caseSpecs,
    Map<String, dynamic>? motherboardSpecs,
  ) {
    final hints = <String>[];

    if (caseSpecs != null && caseSpecs['max_gpu_length'] != null) {
      final maxLength = caseSpecs['max_gpu_length'];
      hints.add('Max GPU length: ${maxLength}mm');
    }

    if (motherboardSpecs != null && motherboardSpecs['pcie_slots'] != null) {
      hints.add('Available PCIe slots on motherboard');
    }

    if (hints.isEmpty) {
      return 'Graphics card is optional but recommended for gaming';
    }

    return hints.join(' • ');
  }

  /// Generate hint for PSU selection based on total TDP
  static String? getPsuHint(int totalTdp, int? recommendedWattage) {
    if (recommendedWattage != null && recommendedWattage > 0) {
      return 'Based on your components (${totalTdp}W TDP), we recommend at least ${recommendedWattage}W PSU';
    }

    return 'Power supply wattage should cover all components with headroom';
  }

  /// Generate hint for case selection based on motherboard
  static String? getCaseHint(Map<String, dynamic>? motherboardSpecs) {
    if (motherboardSpecs == null || motherboardSpecs['form_factor'] == null) {
      return 'Select a motherboard first to see compatible cases';
    }

    final formFactor = motherboardSpecs['form_factor'];
    return 'Your motherboard ($formFactor) requires a compatible case size';
  }

  /// Generate hint for CPU cooler selection based on CPU and case
  static String? getCoolerHint(
    Map<String, dynamic>? cpuSpecs,
    Map<String, dynamic>? caseSpecs,
  ) {
    final hints = <String>[];

    if (cpuSpecs != null && cpuSpecs['socket'] != null) {
      hints.add('Must support ${cpuSpecs['socket']} socket');
    }

    if (caseSpecs != null && caseSpecs['max_cooler_height'] != null) {
      final maxHeight = caseSpecs['max_cooler_height'];
      hints.add('Max height: ${maxHeight}mm');
    }

    if (hints.isEmpty) {
      return 'CPU cooler is optional but recommended for better performance';
    }

    return hints.join(' • ');
  }

  /// Generate hint for storage selection
  static String? getStorageHint(Map<String, dynamic>? motherboardSpecs) {
    if (motherboardSpecs != null && motherboardSpecs['m2_slots'] != null) {
      final m2Slots = motherboardSpecs['m2_slots'];
      return 'Your motherboard has $m2Slots M.2 slot(s) for NVMe SSDs';
    }

    return 'SSD recommended for operating system and frequently used programs';
  }
}
