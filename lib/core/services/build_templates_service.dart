import '../../data/models/build_template.dart';
import '../../data/models/component.dart';

/// Service for managing build templates and component matching
class BuildTemplatesService {
  /// Get all available build templates
  List<BuildTemplate> getAllTemplates() {
    return _buildTemplates;
  }

  /// Get templates by category
  List<BuildTemplate> getTemplatesByCategory(BuildTemplateCategory category) {
    return _buildTemplates.where((t) => t.category == category).toList();
  }

  /// Get template by ID
  BuildTemplate? getTemplateById(String id) {
    try {
      return _buildTemplates.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Match a component to a template and return a compatibility score
  /// Higher score means better match
  int matchComponentToTemplate(
    Component component,
    BuildTemplate template,
    String category,
  ) {
    int score = 0;
    final recommendations = template.recommendations.getForCategory(category);

    if (recommendations.isEmpty) return 0;

    // Check if component name/brand matches any recommendation
    final componentText = '${component.brand} ${component.name}'.toLowerCase();

    for (final rec in recommendations) {
      if (componentText.contains(rec.toLowerCase())) {
        score += 10;
      }
    }

    // Additional scoring based on specs
    if (component.specs != null) {
      final specs = component.specs!;

      // RAM capacity matching
      if (category == 'memory' && template.targetSpecs.ramCapacityGB != null) {
        final capacity = _extractNumber(specs['capacity_gb']) ??
                        _extractNumber(specs['capacity']) ?? 0;
        if (capacity >= template.targetSpecs.ramCapacityGB!) {
          score += 5;
        }
      }

      // Storage capacity matching
      if (category == 'internal-hard-drive' && template.targetSpecs.storageGB != null) {
        final capacity = _extractNumber(specs['capacity']) ??
                        _extractNumber(specs['capacity_gb']) ?? 0;
        if (capacity >= template.targetSpecs.storageGB!) {
          score += 5;
        }
      }

      // PSU wattage matching
      if (category == 'power-supply' && template.targetSpecs.psuWattage != null) {
        final wattage = _extractNumber(specs['wattage']) ??
                       _extractWattageFromName(component.name);
        if (wattage >= template.targetSpecs.psuWattage!) {
          score += 5;
        }
      }

      // CPU cores matching
      if (category == 'cpu' && template.targetSpecs.cpuCores != null) {
        final cores = _extractNumber(specs['cores']) ??
                     _extractNumber(specs['core_count']) ?? 0;
        if (cores >= template.targetSpecs.cpuCores!) {
          score += 5;
        }
      }
    }

    return score;
  }

  /// Get suggested components sorted by compatibility score
  /// Returns top matching components for a specific category
  List<Component> getSuggestedComponents(
    List<Component> components,
    BuildTemplate template,
    String category,
  ) {
    // Score all components
    final scored = components.map((comp) => {
          'component': comp,
          'score': matchComponentToTemplate(comp, template, category),
        }).toList();

    // Sort by score descending, then by price ascending
    scored.sort((a, b) {
      final scoreA = a['score'] as int;
      final scoreB = b['score'] as int;

      if (scoreB != scoreA) return scoreB - scoreA;

      final compA = a['component'] as Component;
      final compB = b['component'] as Component;
      final priceA = compA.priceBdt ?? double.infinity;
      final priceB = compB.priceBdt ?? double.infinity;

      return priceA.compareTo(priceB);
    });

    // Return top 10 components with score > 0
    return scored
        .where((s) => (s['score'] as int) > 0)
        .take(10)
        .map((s) => s['component'] as Component)
        .toList();
  }

  /// Extract number from dynamic value
  int _extractNumber(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      // Try to extract first number from string
      final match = RegExp(r'\d+').firstMatch(value);
      return match != null ? int.parse(match.group(0)!) : 0;
    }
    return 0;
  }

  /// Extract wattage from component name (e.g., "650W PSU" -> 650)
  int _extractWattageFromName(String name) {
    final match = RegExp(r'(\d{3,4})\s*W', caseSensitive: false).firstMatch(name);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  /// Pre-configured build templates
  static final List<BuildTemplate> _buildTemplates = [
    // Gaming Beast - Enthusiast
    const BuildTemplate(
      id: 'gaming-ultra',
      name: 'Gaming Beast',
      description: '4K gaming at ultra settings, VR ready, streaming capable',
      budget: '৳250,000 - ৳400,000',
      category: BuildTemplateCategory.enthusiast,
      icon: '🔥',
      targetSpecs: TargetSpecs(
        cpuCores: 12,
        ramCapacityGB: 32,
        storageGB: 2000,
        gpuTier: GpuTier.ultra,
        psuWattage: 850,
      ),
      recommendations: ComponentRecommendations(
        cpu: ['AMD Ryzen 9', 'Intel Core i9'],
        motherboard: ['X670', 'Z790'],
        memory: ['DDR5', '32GB', '6000MHz'],
        videoCard: ['RTX 4080', 'RTX 4090', 'RX 7900 XTX'],
        internalHardDrive: ['2TB NVMe SSD', '1TB Gen4'],
        powerSupply: ['850W', '1000W', '80+ Gold'],
        caseRecommendations: ['Full Tower', 'Mid Tower ATX'],
        cpuCooler: ['AIO 360mm', 'Tower Cooler'],
      ),
    ),

    // High-End Gaming
    const BuildTemplate(
      id: 'gaming-high',
      name: 'High-End Gaming',
      description: '1440p gaming at high settings, perfect for AAA titles',
      budget: '৳150,000 - ৳250,000',
      category: BuildTemplateCategory.gaming,
      icon: '🎮',
      targetSpecs: TargetSpecs(
        cpuCores: 8,
        ramCapacityGB: 32,
        storageGB: 1000,
        gpuTier: GpuTier.high,
        psuWattage: 750,
      ),
      recommendations: ComponentRecommendations(
        cpu: ['AMD Ryzen 7', 'Intel Core i7'],
        motherboard: ['B650', 'B760'],
        memory: ['DDR5', '32GB', '5200MHz'],
        videoCard: ['RTX 4070', 'RTX 4070 Ti', 'RX 7800 XT'],
        internalHardDrive: ['1TB NVMe SSD', '500GB Gen4'],
        powerSupply: ['750W', '80+ Gold'],
        caseRecommendations: ['Mid Tower ATX'],
        cpuCooler: ['AIO 240mm', 'Tower Cooler'],
      ),
    ),

    // Mid-Range Gaming
    const BuildTemplate(
      id: 'gaming-mid',
      name: 'Mid-Range Gaming',
      description: '1080p gaming at high settings, great value for money',
      budget: '৳80,000 - ৳150,000',
      category: BuildTemplateCategory.gaming,
      icon: '🎯',
      targetSpecs: TargetSpecs(
        cpuCores: 6,
        ramCapacityGB: 16,
        storageGB: 500,
        gpuTier: GpuTier.mid,
        psuWattage: 650,
      ),
      recommendations: ComponentRecommendations(
        cpu: ['AMD Ryzen 5', 'Intel Core i5'],
        motherboard: ['B550', 'B660'],
        memory: ['DDR4', '16GB', '3200MHz'],
        videoCard: ['RTX 4060', 'RTX 3060', 'RX 6700 XT'],
        internalHardDrive: ['500GB NVMe SSD', '1TB HDD'],
        powerSupply: ['650W', '80+ Bronze'],
        caseRecommendations: ['Mid Tower ATX', 'Micro ATX'],
        cpuCooler: ['Stock Cooler', 'Tower Cooler'],
      ),
    ),

    // Budget Gaming
    const BuildTemplate(
      id: 'gaming-budget',
      name: 'Budget Gaming',
      description: '1080p gaming at medium settings, affordable entry point',
      budget: '৳50,000 - ৳80,000',
      category: BuildTemplateCategory.budget,
      icon: '💰',
      targetSpecs: TargetSpecs(
        cpuCores: 4,
        ramCapacityGB: 16,
        storageGB: 500,
        gpuTier: GpuTier.entry,
        psuWattage: 550,
      ),
      recommendations: ComponentRecommendations(
        cpu: ['AMD Ryzen 3', 'Intel Core i3'],
        motherboard: ['A520', 'H610'],
        memory: ['DDR4', '16GB', '2666MHz'],
        videoCard: ['GTX 1650', 'RX 6500 XT'],
        internalHardDrive: ['256GB SSD', '500GB HDD'],
        powerSupply: ['550W', '80+ Bronze'],
        caseRecommendations: ['Micro ATX', 'Mini Tower'],
        cpuCooler: ['Stock Cooler'],
      ),
    ),

    // Professional Workstation
    const BuildTemplate(
      id: 'workstation-pro',
      name: 'Professional Workstation',
      description: 'Content creation, 3D rendering, video editing powerhouse',
      budget: '৳200,000 - ৳350,000',
      category: BuildTemplateCategory.workstation,
      icon: '💼',
      targetSpecs: TargetSpecs(
        cpuCores: 16,
        ramCapacityGB: 64,
        storageGB: 2000,
        gpuTier: GpuTier.high,
        psuWattage: 850,
      ),
      recommendations: ComponentRecommendations(
        cpu: ['AMD Ryzen 9', 'Intel Core i9', 'Threadripper'],
        motherboard: ['X670', 'Z790', 'TRX40'],
        memory: ['DDR5', '64GB', 'ECC'],
        videoCard: ['RTX 4070', 'RTX 4080', 'Quadro'],
        internalHardDrive: ['2TB NVMe SSD', '4TB HDD'],
        powerSupply: ['850W', '1000W', '80+ Gold'],
        caseRecommendations: ['Full Tower', 'Workstation Case'],
        cpuCooler: ['AIO 360mm', 'Noctua NH-D15'],
      ),
    ),

    // Mid-Range Workstation
    const BuildTemplate(
      id: 'workstation-mid',
      name: 'Mid-Range Workstation',
      description: 'Photo editing, light video work, productivity tasks',
      budget: '৳100,000 - ৳200,000',
      category: BuildTemplateCategory.workstation,
      icon: '📊',
      targetSpecs: TargetSpecs(
        cpuCores: 8,
        ramCapacityGB: 32,
        storageGB: 1000,
        gpuTier: GpuTier.mid,
        psuWattage: 650,
      ),
      recommendations: ComponentRecommendations(
        cpu: ['AMD Ryzen 7', 'Intel Core i7'],
        motherboard: ['B650', 'B760'],
        memory: ['DDR5', '32GB'],
        videoCard: ['RTX 4060', 'Quadro P2200'],
        internalHardDrive: ['1TB NVMe SSD', '2TB HDD'],
        powerSupply: ['650W', '80+ Gold'],
        caseRecommendations: ['Mid Tower ATX'],
        cpuCooler: ['Tower Cooler', 'AIO 240mm'],
      ),
    ),

    // Office Professional
    const BuildTemplate(
      id: 'office-pro',
      name: 'Office Professional',
      description: 'Business tasks, multitasking, reliable and efficient',
      budget: '৳40,000 - ৳70,000',
      category: BuildTemplateCategory.office,
      icon: '🏢',
      targetSpecs: TargetSpecs(
        cpuCores: 6,
        ramCapacityGB: 16,
        storageGB: 500,
        psuWattage: 450,
      ),
      recommendations: ComponentRecommendations(
        cpu: ['AMD Ryzen 5', 'Intel Core i5'],
        motherboard: ['B550', 'B660'],
        memory: ['DDR4', '16GB'],
        videoCard: [], // Optional - integrated graphics
        internalHardDrive: ['512GB SSD', '1TB HDD'],
        powerSupply: ['450W', '80+ Bronze'],
        caseRecommendations: ['Micro ATX', 'SFF'],
        cpuCooler: ['Stock Cooler'],
      ),
    ),

    // Basic Office
    const BuildTemplate(
      id: 'office-budget',
      name: 'Basic Office',
      description: 'Web browsing, documents, email, basic tasks',
      budget: '৳25,000 - ৳40,000',
      category: BuildTemplateCategory.office,
      icon: '📝',
      targetSpecs: TargetSpecs(
        cpuCores: 4,
        ramCapacityGB: 8,
        storageGB: 256,
        psuWattage: 400,
      ),
      recommendations: ComponentRecommendations(
        cpu: ['AMD Ryzen 3', 'Intel Core i3', 'Pentium'],
        motherboard: ['A520', 'H610'],
        memory: ['DDR4', '8GB'],
        videoCard: [], // Integrated graphics only
        internalHardDrive: ['256GB SSD', '500GB HDD'],
        powerSupply: ['400W', '80+ Bronze'],
        caseRecommendations: ['Micro ATX', 'Mini ITX'],
        cpuCooler: ['Stock Cooler'],
      ),
    ),
  ];
}
