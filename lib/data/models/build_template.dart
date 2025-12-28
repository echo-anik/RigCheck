/// Represents a pre-configured build template
class BuildTemplate {
  final String id;
  final String name;
  final String description;
  final String budget;
  final BuildTemplateCategory category;
  final String icon;
  final TargetSpecs targetSpecs;
  final ComponentRecommendations recommendations;

  const BuildTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.budget,
    required this.category,
    required this.icon,
    required this.targetSpecs,
    required this.recommendations,
  });

  factory BuildTemplate.fromJson(Map<String, dynamic> json) {
    return BuildTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      budget: json['budget'] as String,
      category: BuildTemplateCategory.fromString(json['category'] as String),
      icon: json['icon'] as String,
      targetSpecs: TargetSpecs.fromJson(json['targetSpecs'] as Map<String, dynamic>),
      recommendations: ComponentRecommendations.fromJson(
        json['recommendations'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'budget': budget,
      'category': category.toString(),
      'icon': icon,
      'targetSpecs': targetSpecs.toJson(),
      'recommendations': recommendations.toJson(),
    };
  }
}

/// Build template categories
enum BuildTemplateCategory {
  gaming,
  workstation,
  office,
  budget,
  enthusiast;

  static BuildTemplateCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'gaming':
        return BuildTemplateCategory.gaming;
      case 'workstation':
        return BuildTemplateCategory.workstation;
      case 'office':
        return BuildTemplateCategory.office;
      case 'budget':
        return BuildTemplateCategory.budget;
      case 'enthusiast':
        return BuildTemplateCategory.enthusiast;
      default:
        return BuildTemplateCategory.gaming;
    }
  }

  @override
  String toString() {
    switch (this) {
      case BuildTemplateCategory.gaming:
        return 'gaming';
      case BuildTemplateCategory.workstation:
        return 'workstation';
      case BuildTemplateCategory.office:
        return 'office';
      case BuildTemplateCategory.budget:
        return 'budget';
      case BuildTemplateCategory.enthusiast:
        return 'enthusiast';
    }
  }

  String get displayName {
    switch (this) {
      case BuildTemplateCategory.gaming:
        return 'Gaming';
      case BuildTemplateCategory.workstation:
        return 'Workstation';
      case BuildTemplateCategory.office:
        return 'Office';
      case BuildTemplateCategory.budget:
        return 'Budget';
      case BuildTemplateCategory.enthusiast:
        return 'Enthusiast';
    }
  }
}

/// GPU tier classification
enum GpuTier {
  entry,
  mid,
  high,
  ultra;

  static GpuTier fromString(String value) {
    switch (value.toLowerCase()) {
      case 'entry':
        return GpuTier.entry;
      case 'mid':
        return GpuTier.mid;
      case 'high':
        return GpuTier.high;
      case 'ultra':
        return GpuTier.ultra;
      default:
        return GpuTier.mid;
    }
  }

  @override
  String toString() {
    switch (this) {
      case GpuTier.entry:
        return 'entry';
      case GpuTier.mid:
        return 'mid';
      case GpuTier.high:
        return 'high';
      case GpuTier.ultra:
        return 'ultra';
    }
  }
}

/// Target specifications for a build template
class TargetSpecs {
  final int? cpuCores;
  final int? ramCapacityGB;
  final int? storageGB;
  final GpuTier? gpuTier;
  final int? psuWattage;

  const TargetSpecs({
    this.cpuCores,
    this.ramCapacityGB,
    this.storageGB,
    this.gpuTier,
    this.psuWattage,
  });

  factory TargetSpecs.fromJson(Map<String, dynamic> json) {
    return TargetSpecs(
      cpuCores: json['cpuCores'] as int?,
      ramCapacityGB: json['ramCapacityGB'] as int?,
      storageGB: json['storageGB'] as int?,
      gpuTier: json['gpuTier'] != null
          ? GpuTier.fromString(json['gpuTier'] as String)
          : null,
      psuWattage: json['psuWattage'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpuCores': cpuCores,
      'ramCapacityGB': ramCapacityGB,
      'storageGB': storageGB,
      'gpuTier': gpuTier?.toString(),
      'psuWattage': psuWattage,
    };
  }
}

/// Component recommendations for each category
class ComponentRecommendations {
  final List<String> cpu;
  final List<String> motherboard;
  final List<String> memory;
  final List<String> videoCard;
  final List<String> internalHardDrive;
  final List<String> powerSupply;
  final List<String> caseRecommendations;
  final List<String> cpuCooler;

  const ComponentRecommendations({
    this.cpu = const [],
    this.motherboard = const [],
    this.memory = const [],
    this.videoCard = const [],
    this.internalHardDrive = const [],
    this.powerSupply = const [],
    this.caseRecommendations = const [],
    this.cpuCooler = const [],
  });

  factory ComponentRecommendations.fromJson(Map<String, dynamic> json) {
    return ComponentRecommendations(
      cpu: (json['cpu'] as List?)?.map((e) => e.toString()).toList() ?? [],
      motherboard: (json['motherboard'] as List?)?.map((e) => e.toString()).toList() ?? [],
      memory: (json['memory'] as List?)?.map((e) => e.toString()).toList() ?? [],
      videoCard: (json['video-card'] as List?)?.map((e) => e.toString()).toList() ?? [],
      internalHardDrive: (json['internal-hard-drive'] as List?)?.map((e) => e.toString()).toList() ?? [],
      powerSupply: (json['power-supply'] as List?)?.map((e) => e.toString()).toList() ?? [],
      caseRecommendations: (json['case'] as List?)?.map((e) => e.toString()).toList() ?? [],
      cpuCooler: (json['cpu-cooler'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpu': cpu,
      'motherboard': motherboard,
      'memory': memory,
      'video-card': videoCard,
      'internal-hard-drive': internalHardDrive,
      'power-supply': powerSupply,
      'case': caseRecommendations,
      'cpu-cooler': cpuCooler,
    };
  }

  /// Get recommendations for a specific category
  List<String> getForCategory(String category) {
    switch (category) {
      case 'cpu':
        return cpu;
      case 'motherboard':
        return motherboard;
      case 'memory':
        return memory;
      case 'video-card':
        return videoCard;
      case 'internal-hard-drive':
        return internalHardDrive;
      case 'power-supply':
        return powerSupply;
      case 'case':
        return caseRecommendations;
      case 'cpu-cooler':
        return cpuCooler;
      default:
        return [];
    }
  }
}
