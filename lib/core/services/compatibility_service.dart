import '../network/api_client.dart';
import '../constants/api_constants.dart';
import '../../data/models/component.dart';

/// Severity level for compatibility issues
enum IssueSeverity {
  error,
  warning,
}

/// Base class for compatibility issues
abstract class CompatibilityIssue {
  final String message;
  final IssueSeverity severity;
  final String category;

  const CompatibilityIssue({
    required this.message,
    required this.severity,
    required this.category,
  });

  bool get isError => severity == IssueSeverity.error;
  bool get isWarning => severity == IssueSeverity.warning;
}

/// Represents a compatibility error (critical issue)
class CompatibilityError extends CompatibilityIssue {
  const CompatibilityError({
    required String message,
    required String category,
  }) : super(
          message: message,
          severity: IssueSeverity.error,
          category: category,
        );
}

/// Represents a compatibility warning (non-critical issue)
class CompatibilityWarning extends CompatibilityIssue {
  const CompatibilityWarning({
    required String message,
    required String category,
  }) : super(
          message: message,
          severity: IssueSeverity.warning,
          category: category,
        );
}

class CompatibilityCheckResult {
  final bool isValid;
  final List<String> warnings;
  final List<String> errors;
  final double totalCostBdt;
  final int totalTdpW;
  final int recommendedPsuW;
  final Map<String, dynamic> compatibilityChecks;

  CompatibilityCheckResult({
    required this.isValid,
    required this.warnings,
    required this.errors,
    required this.totalCostBdt,
    required this.totalTdpW,
    required this.recommendedPsuW,
    required this.compatibilityChecks,
  });

  factory CompatibilityCheckResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final summary = data['summary'] as Map<String, dynamic>;

    return CompatibilityCheckResult(
      isValid: data['valid'] as bool,
      warnings: (data['warnings'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      errors:
          (data['errors'] as List?)?.map((e) => e.toString()).toList() ?? [],
      totalCostBdt: (summary['total_cost_bdt'] as num).toDouble(),
      totalTdpW: summary['total_tdp_w'] as int,
      recommendedPsuW: summary['recommended_psu_w'] as int,
      compatibilityChecks:
          data['compatibility_checks'] as Map<String, dynamic>,
    );
  }

  /// Get status based on errors and warnings
  String get status {
    if (errors.isNotEmpty) {
      return 'errors';
    } else if (warnings.isNotEmpty) {
      return 'warnings';
    } else {
      return 'valid';
    }
  }

  /// Convert to notes JSON for Build model
  Map<String, dynamic> toNotesJson() {
    return {
      'warnings': warnings,
      'errors': errors,
      'checks': compatibilityChecks,
    };
  }
}

/// Local compatibility validation result
class LocalCompatibilityResult {
  final List<CompatibilityIssue> issues;
  final int totalTdp;
  final int recommendedPsuWattage;

  LocalCompatibilityResult({
    required this.issues,
    required this.totalTdp,
    required this.recommendedPsuWattage,
  });

  bool get isValid => errors.isEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;

  List<CompatibilityError> get errors =>
      issues.whereType<CompatibilityError>().toList();

  List<CompatibilityWarning> get warnings =>
      issues.whereType<CompatibilityWarning>().toList();

  String get status {
    if (hasErrors) return 'errors';
    if (hasWarnings) return 'warnings';
    return 'valid';
  }
}

class CompatibilityService {
  final ApiClient _apiClient;

  CompatibilityService(this._apiClient);

  /// Safely parse a numeric value from specs (handles int, num, String)
  int? _parseNumericSpec(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value.replaceAll(RegExp(r'[^\d]'), ''));
    }
    return null;
  }

  /// Validate a build configuration
  ///
  /// [components] should be a map of category to product_id:
  /// {
  ///   'cpu': 'product_id_123',
  ///   'motherboard': 'product_id_456',
  ///   'gpu': 'product_id_789',
  ///   ...
  /// }
  Future<CompatibilityCheckResult?> validateBuild(
    Map<String, String> components,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.validateBuild,
        data: {
          'components': components,
        },
      );

      if (response.statusCode == 200) {
        return CompatibilityCheckResult.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Failed to validate build: $e');
    }
  }

  /// Get all compatibility rules from the backend
  Future<List<Map<String, dynamic>>> getCompatibilityRules() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.compatibilityRules,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((rule) => rule as Map<String, dynamic>).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load compatibility rules: $e');
    }
  }

  /// Comprehensive local compatibility validation for a build
  /// Checks socket, RAM, PSU, form factor, and other compatibility issues
  LocalCompatibilityResult validateBuildLocally(
      Map<String, Component> components) {
    final issues = <CompatibilityIssue>[];

    // Calculate TDP first as it's needed for PSU check
    final totalTdp = _calculateTotalTdp(components);
    final recommendedPsu = _calculateRecommendedPsu(totalTdp);

    // Check CPU and Motherboard socket compatibility
    issues.addAll(_checkSocketCompatibility(components));

    // Check RAM compatibility
    issues.addAll(_checkRamCompatibility(components));

    // Check PSU wattage
    issues.addAll(_checkPsuCompatibility(components, totalTdp, recommendedPsu));

    // Check case and motherboard form factor
    issues.addAll(_checkFormFactorCompatibility(components));

    // Check GPU clearance
    issues.addAll(_checkGpuClearance(components));

    // Check cooler compatibility
    issues.addAll(_checkCoolerCompatibility(components));

    // Check storage interface compatibility
    issues.addAll(_checkStorageCompatibility(components));

    return LocalCompatibilityResult(
      issues: issues,
      totalTdp: totalTdp,
      recommendedPsuWattage: recommendedPsu,
    );
  }

  /// Check if CPU socket matches motherboard socket
  List<CompatibilityIssue> _checkSocketCompatibility(
      Map<String, Component> components) {
    final issues = <CompatibilityIssue>[];
    final cpu = components['cpu'];
    final motherboard = components['motherboard'];

    if (cpu == null || motherboard == null) return issues;

    final cpuSocket = cpu.specs?['socket'];
    final mbSocket = motherboard.specs?['socket'];

    if (cpuSocket != null && mbSocket != null) {
      if (cpuSocket.toString().toLowerCase() !=
          mbSocket.toString().toLowerCase()) {
        issues.add(CompatibilityError(
          message:
              'CPU socket ($cpuSocket) does not match motherboard socket ($mbSocket)',
          category: 'socket',
        ));
      }
    }

    return issues;
  }

  /// Check RAM compatibility with motherboard
  List<CompatibilityIssue> _checkRamCompatibility(
      Map<String, Component> components) {
    final issues = <CompatibilityIssue>[];
    final ram = components['memory'];
    final motherboard = components['motherboard'];

    if (ram == null || motherboard == null) return issues;

    // Check DDR generation compatibility
    final ramSpeed = ram.specs?['speed'];
    final mbMemoryType = motherboard.specs?['memory_type'];

    if (ramSpeed is List && ramSpeed.isNotEmpty && mbMemoryType != null) {
      final ramGeneration = 'DDR${ramSpeed[0]}';
      if (!mbMemoryType.toString().toUpperCase().contains(ramGeneration)) {
        issues.add(CompatibilityError(
          message:
              'RAM type ($ramGeneration) is not compatible with motherboard memory type ($mbMemoryType)',
          category: 'memory',
        ));
      }
    }

    // Check RAM capacity vs motherboard max memory
    final ramModules = ram.specs?['modules'];
    final mbMaxMemory = _parseNumericSpec(motherboard.specs?['memory_max']);

    if (ramModules is List &&
        ramModules.length >= 2 &&
        mbMaxMemory != null) {
      final totalRamGb = ramModules[0] * ramModules[1];
      if (totalRamGb > mbMaxMemory) {
        issues.add(CompatibilityWarning(
          message:
              'Total RAM capacity (${totalRamGb}GB) exceeds motherboard maximum (${mbMaxMemory}GB)',
          category: 'memory',
        ));
      }
    }

    return issues;
  }

  /// Check PSU wattage sufficiency
  List<CompatibilityIssue> _checkPsuCompatibility(
    Map<String, Component> components,
    int totalTdp,
    int recommendedPsu,
  ) {
    final issues = <CompatibilityIssue>[];
    final psu = components['power-supply'];

    if (psu == null) return issues;

    final psuWattage = psu.specs?['wattage'];
    final wattage = _parseNumericSpec(psuWattage);

    if (wattage != null) {
      if (wattage < recommendedPsu) {
        issues.add(CompatibilityError(
          message:
              'PSU wattage (${wattage}W) is insufficient. Recommended: ${recommendedPsu}W for ${totalTdp}W TDP',
          category: 'power',
        ));
      } else if (wattage < recommendedPsu + 100) {
        issues.add(CompatibilityWarning(
          message:
              'PSU wattage (${wattage}W) is adequate but close to limit. Consider ${recommendedPsu + 150}W for better headroom',
          category: 'power',
        ));
      }
    }

    return issues;
  }

  /// Check case and motherboard form factor compatibility
  List<CompatibilityIssue> _checkFormFactorCompatibility(
      Map<String, Component> components) {
    final issues = <CompatibilityIssue>[];
    final motherboard = components['motherboard'];
    final pcCase = components['case'];

    if (motherboard == null || pcCase == null) return issues;

    final mbFormFactor = motherboard.specs?['form_factor'];
    final caseFormFactor = pcCase.specs?['form_factor'];

    if (mbFormFactor != null && caseFormFactor != null) {
      final mbFF = mbFormFactor.toString().toUpperCase();
      final caseFF = caseFormFactor.toString().toUpperCase();

      // Standard form factor hierarchy: E-ATX > ATX > Micro-ATX > Mini-ITX
      final formFactorSizes = {
        'E-ATX': 4,
        'EATX': 4,
        'ATX': 3,
        'MICRO-ATX': 2,
        'MATX': 2,
        'MINI-ITX': 1,
        'ITX': 1,
      };

      final mbSize = formFactorSizes[mbFF] ?? 0;
      final caseSize = formFactorSizes[caseFF] ?? 0;

      if (mbSize > caseSize && mbSize > 0 && caseSize > 0) {
        issues.add(CompatibilityError(
          message:
              'Motherboard form factor ($mbFormFactor) may not fit in case ($caseFormFactor)',
          category: 'form_factor',
        ));
      }
    }

    return issues;
  }

  /// Check GPU clearance in case
  List<CompatibilityIssue> _checkGpuClearance(
      Map<String, Component> components) {
    final issues = <CompatibilityIssue>[];
    final gpu = components['video-card'];
    final pcCase = components['case'];

    if (gpu == null || pcCase == null) return issues;

    final gpuLength = _parseNumericSpec(gpu.specs?['length']);
    final caseGpuLength = _parseNumericSpec(pcCase.specs?['maximum_video_card_length']);

    if (gpuLength != null && caseGpuLength != null) {
      if (gpuLength > caseGpuLength) {
        issues.add(CompatibilityError(
          message:
              'GPU length (${gpuLength}mm) exceeds case maximum (${caseGpuLength}mm)',
          category: 'clearance',
        ));
      } else if (gpuLength > caseGpuLength - 20) {
        issues.add(CompatibilityWarning(
          message:
              'GPU length (${gpuLength}mm) is very close to case maximum (${caseGpuLength}mm). Verify clearance',
          category: 'clearance',
        ));
      }
    }

    return issues;
  }

  /// Check CPU cooler compatibility
  List<CompatibilityIssue> _checkCoolerCompatibility(
      Map<String, Component> components) {
    final issues = <CompatibilityIssue>[];
    final cooler = components['cpu-cooler'];
    final cpu = components['cpu'];
    final pcCase = components['case'];

    if (cooler == null) return issues;

    // Check cooler socket compatibility with CPU
    if (cpu != null) {
      final cpuSocket = cpu.specs?['socket'];
      final coolerSockets = cooler.specs?['sockets'];

      if (cpuSocket != null && coolerSockets is List) {
        final socketSupported = coolerSockets.any((s) =>
            s.toString().toLowerCase() == cpuSocket.toString().toLowerCase());

        if (!socketSupported) {
          issues.add(CompatibilityError(
            message:
                'CPU cooler does not support CPU socket ($cpuSocket). Supported: ${coolerSockets.join(", ")}',
            category: 'cooler',
          ));
        }
      }
    }

    // Check cooler height vs case clearance
    if (pcCase != null) {
      final coolerHeight = _parseNumericSpec(cooler.specs?['height']);
      final caseMaxCoolerHeight = _parseNumericSpec(pcCase.specs?['maximum_cpu_cooler_height']);

      if (coolerHeight != null && caseMaxCoolerHeight != null) {
        if (coolerHeight > caseMaxCoolerHeight) {
          issues.add(CompatibilityError(
            message:
                'CPU cooler height (${coolerHeight}mm) exceeds case maximum (${caseMaxCoolerHeight}mm)',
            category: 'cooler',
          ));
        }
      }
    }

    return issues;
  }

  /// Check storage interface compatibility
  List<CompatibilityIssue> _checkStorageCompatibility(
      Map<String, Component> components) {
    final issues = <CompatibilityIssue>[];
    final storage = components['internal-hard-drive'];
    final motherboard = components['motherboard'];

    if (storage == null || motherboard == null) return issues;

    final storageInterface = storage.specs?['interface'];

    if (storageInterface != null) {
      final interface = storageInterface.toString().toUpperCase();

      // Check for M.2 NVMe support
      if (interface.contains('M.2') || interface.contains('NVME')) {
        final m2Slots = motherboard.specs?['m2_slots'];

        if (m2Slots == null || m2Slots == 0) {
          issues.add(CompatibilityWarning(
            message:
                'Motherboard may not have M.2 slots for NVMe storage. Verify specifications',
            category: 'storage',
          ));
        }
      }
    }

    return issues;
  }

  /// Calculate total TDP from components
  int _calculateTotalTdp(Map<String, Component> components) {
    int tdp = 0;

    // CPU TDP
    final cpu = components['cpu'];
    if (cpu?.specs?['tdp'] != null) {
      final cpuTdp = _parseNumericSpec(cpu!.specs!['tdp']);
      if (cpuTdp != null) {
        tdp += cpuTdp;
      }
    }

    // GPU TDP (estimate if not available)
    final gpu = components['video-card'];
    if (gpu != null) {
      final gpuTdp = _parseNumericSpec(gpu.specs?['tdp']);
      if (gpuTdp != null) {
        tdp += gpuTdp;
      } else {
        // Estimate based on GPU memory
        final gpuMemory = _parseNumericSpec(gpu.specs?['memory']);
        if (gpuMemory != null) {
          tdp += gpuMemory >= 12 ? 300 : (gpuMemory >= 8 ? 250 : 200);
        } else {
          tdp += 200; // Default GPU TDP estimate
        }
      }
    }

    // Motherboard and other components
    tdp += 50; // Motherboard base
    tdp += components.length * 10; // ~10W per additional component

    return tdp;
  }

  /// Calculate recommended PSU wattage
  int _calculateRecommendedPsu(int totalTdp) {
    // Add 20% headroom plus 100W for peripherals and peaks
    return ((totalTdp + 100) * 1.2).ceil();
  }

  /// Quick check: Does CPU socket match motherboard socket?
  /// This is a simplified local check without API call
  /// Returns null if components don't have socket spec
  static bool? checkSocketCompatibility({
    required Map<String, dynamic>? cpuSpecs,
    required Map<String, dynamic>? motherboardSpecs,
  }) {
    if (cpuSpecs == null || motherboardSpecs == null) {
      return null;
    }

    final cpuSocket = cpuSpecs['socket'];
    final mbSocket = motherboardSpecs['socket'];

    if (cpuSocket == null || mbSocket == null) {
      return null;
    }

    return cpuSocket.toString().toLowerCase() ==
        mbSocket.toString().toLowerCase();
  }

  /// Quick check: Is PSU wattage sufficient?
  /// Returns true if sufficient, false if insufficient, null if can't determine
  static bool? checkPsuWattage({
    required int? psuWattage,
    required int? totalTdp,
  }) {
    if (psuWattage == null || totalTdp == null) {
      return null;
    }

    final recommended = ((totalTdp + 150) * 1.2).ceil();
    return psuWattage >= recommended;
  }
}
