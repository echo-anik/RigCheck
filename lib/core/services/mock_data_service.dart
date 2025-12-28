import '../../data/models/component.dart';
import '../../data/models/build.dart';

class MockDataService {
  static List<Component> getMockComponents({String? category}) {
    final allComponents = [
      // CPUs
      Component(
        id: 1,
        productId: 'intel-i9-14900k',
        name: 'Intel Core i9-14900K',
        category: 'cpu',
        brand: 'Intel',
        priceBdt: 52000,
        imageUrl: null,
        availabilityStatus: 'in_stock',
        popularityScore: 95,
        featured: true,
        specs: {
          'core_count': 24,
          'thread_count': 32,
          'base_clock': 3.2,
          'boost_clock': 6.0,
          'tdp': 125,
          'socket': 'LGA1700',
        },
      ),
      Component(
        id: 2,
        productId: 'amd-ryzen-9-7950x',
        name: 'AMD Ryzen 9 7950X',
        category: 'cpu',
        brand: 'AMD',
        priceBdt: 48000,
        imageUrl: null,
        availabilityStatus: 'in_stock',
        popularityScore: 92,
        featured: true,
        specs: {
          'core_count': 16,
          'thread_count': 32,
          'base_clock': 4.5,
          'boost_clock': 5.7,
          'tdp': 170,
          'socket': 'AM5',
        },
      ),
      Component(
        id: 3,
        productId: 'intel-i5-13600k',
        name: 'Intel Core i5-13600K',
        category: 'cpu',
        brand: 'Intel',
        priceBdt: 28000,
        imageUrl: null,
        availabilityStatus: 'in_stock',
        popularityScore: 88,
        featured: false,
        specs: {
          'core_count': 14,
          'thread_count': 20,
          'base_clock': 3.5,
          'boost_clock': 5.1,
          'tdp': 125,
          'socket': 'LGA1700',
        },
      ),

      // GPUs
      Component(
        id: 4,
        productId: 'nvidia-rtx-4080',
        name: 'NVIDIA GeForce RTX 4080',
        category: 'video-card',
        brand: 'NVIDIA',
        priceBdt: 115000,
        imageUrl: null,
        availabilityStatus: 'in_stock',
        popularityScore: 90,
        featured: true,
        specs: {
          'memory': 16,
          'memory_type': 'GDDR6X',
          'boost_clock': 2505,
          'tdp': 320,
          'length': 304,
        },
      ),
      Component(
        id: 5,
        productId: 'amd-rx-7900-xtx',
        name: 'AMD Radeon RX 7900 XTX',
        category: 'video-card',
        brand: 'AMD',
        priceBdt: 98000,
        imageUrl: null,
        availabilityStatus: 'in_stock',
        popularityScore: 87,
        featured: true,
        specs: {
          'memory': 24,
          'memory_type': 'GDDR6',
          'boost_clock': 2500,
          'tdp': 355,
          'length': 287,
        },
      ),
      Component(
        id: 6,
        productId: 'nvidia-rtx-4070',
        name: 'NVIDIA GeForce RTX 4070',
        category: 'video-card',
        brand: 'NVIDIA',
        priceBdt: 68000,
        imageUrl: null,
        availabilityStatus: 'in_stock',
        popularityScore: 85,
        featured: false,
        specs: {
          'memory': 12,
          'memory_type': 'GDDR6X',
          'boost_clock': 2475,
          'tdp': 200,
          'length': 242,
        },
      ),

      // RAM
      Component(
        id: 7,
        productId: 'corsair-vengeance-32gb',
        name: 'Corsair Vengeance DDR5 32GB (2x16GB)',
        category: 'memory',
        brand: 'Corsair',
        priceBdt: 15000,
        imageUrl: null,
        availabilityStatus: 'in_stock',
        popularityScore: 90,
        featured: true,
        specs: {
          'speed': [5, 6000],
          'modules': [2, 16],
          'cas_latency': 36,
          'voltage': 1.35,
        },
      ),
      Component(
        id: 8,
        productId: 'gskill-trident-32gb',
        name: 'G.Skill Trident Z5 RGB 32GB (2x16GB)',
        category: 'memory',
        brand: 'G.Skill',
        priceBdt: 16500,
        imageUrl: null,
        availabilityStatus: 'in_stock',
        popularityScore: 88,
        featured: false,
        specs: {
          'speed': [5, 6400],
          'modules': [2, 16],
          'cas_latency': 32,
          'voltage': 1.4,
        },
      ),

      // Motherboards
      Component(
        id: 9,
        productId: 'asus-rog-z790',
        name: 'ASUS ROG Strix Z790-E Gaming WiFi',
        category: 'motherboard',
        brand: 'ASUS',
        priceBdt: 42000,
        imageUrl: null,
        availabilityStatus: 'in_stock',
        popularityScore: 92,
        featured: true,
        specs: {
          'socket': 'LGA1700',
          'form_factor': 'ATX',
          'chipset': 'Z790',
          'memory_slots': 4,
          'max_memory': 128,
        },
      ),
      Component(
        id: 10,
        productId: 'msi-b650-tomahawk',
        name: 'MSI MAG B650 Tomahawk WiFi',
        category: 'motherboard',
        brand: 'MSI',
        priceBdt: 22000,
        imageUrl: null,
        availabilityStatus: 'in_stock',
        popularityScore: 89,
        featured: true,
        specs: {
          'socket': 'AM5',
          'form_factor': 'ATX',
          'chipset': 'B650',
          'memory_slots': 4,
          'max_memory': 128,
        },
      ),

      // Storage
      Component(
        id: 11,
        productId: 'samsung-990-pro-2tb',
        name: 'Samsung 990 PRO 2TB NVMe SSD',
        category: 'internal-hard-drive',
        brand: 'Samsung',
        priceBdt: 18000,
        imageUrl: null,
        availabilityStatus: 'in_stock',
        popularityScore: 94,
        featured: true,
        specs: {
          'capacity': 2000,
          'type': 'SSD',
          'interface': 'M.2 NVMe',
          'form_factor': 'M.2 2280',
          'read_speed': 7450,
          'write_speed': 6900,
        },
      ),
      Component(
        id: 12,
        productId: 'wd-black-sn850x-1tb',
        name: 'WD Black SN850X 1TB NVMe SSD',
        category: 'internal-hard-drive',
        brand: 'Western Digital',
        priceBdt: 9500,
        imageUrl: null,
        availabilityStatus: 'in_stock',
        popularityScore: 91,
        featured: false,
        specs: {
          'capacity': 1000,
          'type': 'SSD',
          'interface': 'M.2 NVMe',
          'form_factor': 'M.2 2280',
          'read_speed': 7300,
          'write_speed': 6600,
        },
      ),

      // Power Supplies
      Component(
        id: 13,
        productId: 'corsair-rm850x',
        name: 'Corsair RM850x 850W 80+ Gold',
        category: 'power-supply',
        brand: 'Corsair',
        priceBdt: 14000,
        imageUrl: null,
        availabilityStatus: 'in_stock',
        popularityScore: 93,
        featured: true,
        specs: {
          'wattage': 850,
          'efficiency': '80+ Gold',
          'modular': 'Fully Modular',
          'form_factor': 'ATX',
        },
      ),
      Component(
        id: 14,
        productId: 'evga-supernova-1000',
        name: 'EVGA SuperNOVA 1000 G6 1000W 80+ Gold',
        category: 'power-supply',
        brand: 'EVGA',
        priceBdt: 18500,
        imageUrl: null,
        availabilityStatus: 'in_stock',
        popularityScore: 90,
        featured: false,
        specs: {
          'wattage': 1000,
          'efficiency': '80+ Gold',
          'modular': 'Fully Modular',
          'form_factor': 'ATX',
        },
      ),

      // Cases
      Component(
        id: 15,
        productId: 'lian-li-o11-dynamic',
        name: 'Lian Li O11 Dynamic EVO',
        category: 'case',
        brand: 'Lian Li',
        priceBdt: 16500,
        imageUrl: null,
        availabilityStatus: 'in_stock',
        popularityScore: 95,
        featured: true,
        specs: {
          'form_factor': 'Mid Tower',
          'motherboard_support': 'ATX, Micro-ATX, Mini-ITX',
          'max_gpu_length': 420,
          'max_cpu_cooler_height': 167,
        },
      ),
      Component(
        id: 16,
        productId: 'nzxt-h510-elite',
        name: 'NZXT H510 Elite',
        category: 'case',
        brand: 'NZXT',
        priceBdt: 12000,
        imageUrl: null,
        availabilityStatus: 'in_stock',
        popularityScore: 88,
        featured: false,
        specs: {
          'form_factor': 'Mid Tower',
          'motherboard_support': 'ATX, Micro-ATX, Mini-ITX',
          'max_gpu_length': 381,
          'max_cpu_cooler_height': 165,
        },
      ),

      // CPU Coolers
      Component(
        id: 17,
        productId: 'noctua-nh-d15',
        name: 'Noctua NH-D15 chromax.black',
        category: 'cpu-cooler',
        brand: 'Noctua',
        priceBdt: 11500,
        imageUrl: null,
        availabilityStatus: 'in_stock',
        popularityScore: 96,
        featured: true,
        specs: {
          'type': 'Air Cooler',
          'height': 165,
          'socket_compatibility': 'LGA1700, LGA1200, AM5, AM4',
          'tdp_rating': 220,
        },
      ),
      Component(
        id: 18,
        productId: 'arctic-liquid-360',
        name: 'Arctic Liquid Freezer II 360',
        category: 'cpu-cooler',
        brand: 'Arctic',
        priceBdt: 13500,
        imageUrl: null,
        availabilityStatus: 'in_stock',
        popularityScore: 92,
        featured: true,
        specs: {
          'type': 'AIO Liquid Cooler',
          'radiator_size': 360,
          'socket_compatibility': 'LGA1700, LGA1200, AM5, AM4',
          'tdp_rating': 250,
        },
      ),
      Component(
        id: 19,
        productId: 'cooler-master-212',
        name: 'Cooler Master Hyper 212 RGB Black Edition',
        category: 'cpu-cooler',
        brand: 'Cooler Master',
        priceBdt: 4500,
        imageUrl: null,
        availabilityStatus: 'in_stock',
        popularityScore: 85,
        featured: false,
        specs: {
          'type': 'Air Cooler',
          'height': 159,
          'socket_compatibility': 'LGA1700, LGA1200, AM5, AM4',
          'tdp_rating': 150,
        },
      ),

      // Additional budget options
      Component(
        id: 20,
        productId: 'intel-i3-13100f',
        name: 'Intel Core i3-13100F',
        category: 'cpu',
        brand: 'Intel',
        priceBdt: 12000,
        imageUrl: null,
        availabilityStatus: 'in_stock',
        popularityScore: 82,
        featured: false,
        specs: {
          'core_count': 4,
          'thread_count': 8,
          'base_clock': 3.4,
          'boost_clock': 4.5,
          'tdp': 60,
          'socket': 'LGA1700',
        },
      ),
    ];

    if (category != null) {
      return allComponents.where((c) => c.category == category).toList();
    }

    return allComponents;
  }

  static Component? getMockComponentById(String productId) {
    try {
      return getMockComponents()
          .firstWhere((c) => c.productId == productId);
    } catch (e) {
      return null;
    }
  }

  static List<Build> getMockBuilds({bool publicOnly = false}) {
    final now = DateTime.now();

    final builds = [
      Build(
        id: 1,
        uuid: 'build-uuid-1',
        name: 'High-End Gaming Build',
        description: 'Ultimate gaming performance with RTX 4080 and i9-14900K',
        useCase: 'Gaming',
        totalCost: 450000,
        visibility: 'public',
        compatibilityStatus: 'valid',
        components: {
          'cpu': getMockComponents().firstWhere((c) => c.productId == 'intel-i9-14900k'),
          'video-card': getMockComponents().firstWhere((c) => c.productId == 'nvidia-rtx-4080'),
          'memory': getMockComponents().firstWhere((c) => c.productId == 'corsair-vengeance-32gb'),
          'motherboard': getMockComponents().firstWhere((c) => c.productId == 'asus-rog-z790'),
          'internal-hard-drive': getMockComponents().firstWhere((c) => c.productId == 'samsung-990-pro-2tb'),
          'power-supply': getMockComponents().firstWhere((c) => c.productId == 'corsair-rm850x'),
          'case': getMockComponents().firstWhere((c) => c.productId == 'lian-li-o11-dynamic'),
          'cpu-cooler': getMockComponents().firstWhere((c) => c.productId == 'arctic-liquid-360'),
        },
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Build(
        id: 2,
        uuid: 'build-uuid-2',
        name: 'Budget Gaming PC',
        description: 'Affordable gaming build with great value',
        useCase: 'Budget Gaming',
        totalCost: 150000,
        visibility: 'private',
        compatibilityStatus: 'valid',
        components: {
          'cpu': getMockComponents().firstWhere((c) => c.productId == 'intel-i3-13100f'),
          'video-card': getMockComponents().firstWhere((c) => c.productId == 'nvidia-rtx-4070'),
          'memory': getMockComponents().firstWhere((c) => c.productId == 'corsair-vengeance-32gb'),
          'motherboard': getMockComponents().firstWhere((c) => c.productId == 'msi-b650-tomahawk'),
          'internal-hard-drive': getMockComponents().firstWhere((c) => c.productId == 'wd-black-sn850x-1tb'),
          'power-supply': getMockComponents().firstWhere((c) => c.productId == 'corsair-rm850x'),
          'case': getMockComponents().firstWhere((c) => c.productId == 'nzxt-h510-elite'),
          'cpu-cooler': getMockComponents().firstWhere((c) => c.productId == 'cooler-master-212'),
        },
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Build(
        id: 3,
        uuid: 'build-uuid-3',
        name: 'AMD Workstation',
        description: 'Powerful workstation for content creation',
        useCase: 'Content Creation',
        totalCost: 380000,
        visibility: 'public',
        compatibilityStatus: 'valid',
        components: {
          'cpu': getMockComponents().firstWhere((c) => c.productId == 'amd-ryzen-9-7950x'),
          'video-card': getMockComponents().firstWhere((c) => c.productId == 'amd-rx-7900-xtx'),
          'memory': getMockComponents().firstWhere((c) => c.productId == 'gskill-trident-32gb'),
          'motherboard': getMockComponents().firstWhere((c) => c.productId == 'msi-b650-tomahawk'),
          'internal-hard-drive': getMockComponents().firstWhere((c) => c.productId == 'samsung-990-pro-2tb'),
          'power-supply': getMockComponents().firstWhere((c) => c.productId == 'evga-supernova-1000'),
          'case': getMockComponents().firstWhere((c) => c.productId == 'lian-li-o11-dynamic'),
          'cpu-cooler': getMockComponents().firstWhere((c) => c.productId == 'noctua-nh-d15'),
        },
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ];

    if (publicOnly) {
      return builds.where((b) => b.visibility == 'public').toList();
    }

    return builds;
  }

  static Build? getMockBuildById(int id) {
    try {
      return getMockBuilds().firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }
}
