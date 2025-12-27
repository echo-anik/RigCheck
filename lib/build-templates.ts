import { Component } from '@/lib/api';

export interface BuildTemplate {
  id: string;
  name: string;
  description: string;
  budget: string;
  category: 'gaming' | 'workstation' | 'office' | 'budget' | 'enthusiast';
  icon: string;
  targetSpecs: {
    cpuCores?: number;
    ramCapacityGB?: number;
    storageGB?: number;
    gpuTier?: 'entry' | 'mid' | 'high' | 'ultra';
    psuWattage?: number;
  };
  recommendations: {
    cpu: string[];
    motherboard: string[];
    ram: string[];
    gpu: string[];
    storage: string[];
    psu: string[];
    case: string[];
    cooler: string[];
  };
}

export const buildTemplates: BuildTemplate[] = [
  {
    id: 'gaming-ultra',
    name: 'Gaming Beast',
    description: '4K gaming at ultra settings, VR ready, streaming capable',
    budget: '৳250,000 - ৳400,000',
    category: 'enthusiast',
    icon: '🔥',
    targetSpecs: {
      cpuCores: 12,
      ramCapacityGB: 32,
      storageGB: 2000,
      gpuTier: 'ultra',
      psuWattage: 850
    },
    recommendations: {
      cpu: ['AMD Ryzen 9', 'Intel Core i9'],
      motherboard: ['X670', 'Z790'],
      ram: ['DDR5', '32GB', '6000MHz'],
      gpu: ['RTX 4080', 'RTX 4090', 'RX 7900 XTX'],
      storage: ['2TB NVMe SSD', '1TB Gen4'],
      psu: ['850W', '1000W', '80+ Gold'],
      case: ['Full Tower', 'Mid Tower ATX'],
      cooler: ['AIO 360mm', 'Tower Cooler']
    }
  },
  {
    id: 'gaming-high',
    name: 'High-End Gaming',
    description: '1440p gaming at high settings, perfect for AAA titles',
    budget: '৳150,000 - ৳250,000',
    category: 'gaming',
    icon: '🎮',
    targetSpecs: {
      cpuCores: 8,
      ramCapacityGB: 32,
      storageGB: 1000,
      gpuTier: 'high',
      psuWattage: 750
    },
    recommendations: {
      cpu: ['AMD Ryzen 7', 'Intel Core i7'],
      motherboard: ['B650', 'B760'],
      ram: ['DDR5', '32GB', '5200MHz'],
      gpu: ['RTX 4070', 'RTX 4070 Ti', 'RX 7800 XT'],
      storage: ['1TB NVMe SSD', '500GB Gen4'],
      psu: ['750W', '80+ Gold'],
      case: ['Mid Tower ATX'],
      cooler: ['AIO 240mm', 'Tower Cooler']
    }
  },
  {
    id: 'gaming-mid',
    name: 'Mid-Range Gaming',
    description: '1080p gaming at high settings, great value for money',
    budget: '৳80,000 - ৳150,000',
    category: 'gaming',
    icon: '🎯',
    targetSpecs: {
      cpuCores: 6,
      ramCapacityGB: 16,
      storageGB: 500,
      gpuTier: 'mid',
      psuWattage: 650
    },
    recommendations: {
      cpu: ['AMD Ryzen 5', 'Intel Core i5'],
      motherboard: ['B550', 'B660'],
      ram: ['DDR4', '16GB', '3200MHz'],
      gpu: ['RTX 4060', 'RTX 3060', 'RX 6700 XT'],
      storage: ['500GB NVMe SSD', '1TB HDD'],
      psu: ['650W', '80+ Bronze'],
      case: ['Mid Tower ATX', 'Micro ATX'],
      cooler: ['Stock Cooler', 'Tower Cooler']
    }
  },
  {
    id: 'gaming-budget',
    name: 'Budget Gaming',
    description: '1080p gaming at medium settings, affordable entry point',
    budget: '৳50,000 - ৳80,000',
    category: 'budget',
    icon: '💰',
    targetSpecs: {
      cpuCores: 4,
      ramCapacityGB: 16,
      storageGB: 500,
      gpuTier: 'entry',
      psuWattage: 550
    },
    recommendations: {
      cpu: ['AMD Ryzen 3', 'Intel Core i3'],
      motherboard: ['A520', 'H610'],
      ram: ['DDR4', '16GB', '2666MHz'],
      gpu: ['GTX 1650', 'RX 6500 XT'],
      storage: ['256GB SSD', '500GB HDD'],
      psu: ['550W', '80+ Bronze'],
      case: ['Micro ATX', 'Mini Tower'],
      cooler: ['Stock Cooler']
    }
  },
  {
    id: 'workstation-pro',
    name: 'Professional Workstation',
    description: 'Content creation, 3D rendering, video editing powerhouse',
    budget: '৳200,000 - ৳350,000',
    category: 'workstation',
    icon: '💼',
    targetSpecs: {
      cpuCores: 16,
      ramCapacityGB: 64,
      storageGB: 2000,
      gpuTier: 'high',
      psuWattage: 850
    },
    recommendations: {
      cpu: ['AMD Ryzen 9', 'Intel Core i9', 'Threadripper'],
      motherboard: ['X670', 'Z790', 'TRX40'],
      ram: ['DDR5', '64GB', 'ECC'],
      gpu: ['RTX 4070', 'RTX 4080', 'Quadro'],
      storage: ['2TB NVMe SSD', '4TB HDD'],
      psu: ['850W', '1000W', '80+ Gold'],
      case: ['Full Tower', 'Workstation Case'],
      cooler: ['AIO 360mm', 'Noctua NH-D15']
    }
  },
  {
    id: 'workstation-mid',
    name: 'Mid-Range Workstation',
    description: 'Photo editing, light video work, productivity tasks',
    budget: '৳100,000 - ৳200,000',
    category: 'workstation',
    icon: '📊',
    targetSpecs: {
      cpuCores: 8,
      ramCapacityGB: 32,
      storageGB: 1000,
      gpuTier: 'mid',
      psuWattage: 650
    },
    recommendations: {
      cpu: ['AMD Ryzen 7', 'Intel Core i7'],
      motherboard: ['B650', 'B760'],
      ram: ['DDR5', '32GB'],
      gpu: ['RTX 4060', 'Quadro P2200'],
      storage: ['1TB NVMe SSD', '2TB HDD'],
      psu: ['650W', '80+ Gold'],
      case: ['Mid Tower ATX'],
      cooler: ['Tower Cooler', 'AIO 240mm']
    }
  },
  {
    id: 'office-pro',
    name: 'Office Professional',
    description: 'Business tasks, multitasking, reliable and efficient',
    budget: '৳40,000 - ৳70,000',
    category: 'office',
    icon: '🏢',
    targetSpecs: {
      cpuCores: 6,
      ramCapacityGB: 16,
      storageGB: 500,
      psuWattage: 450
    },
    recommendations: {
      cpu: ['AMD Ryzen 5', 'Intel Core i5'],
      motherboard: ['B550', 'B660'],
      ram: ['DDR4', '16GB'],
      gpu: [], // Optional - integrated graphics
      storage: ['512GB SSD', '1TB HDD'],
      psu: ['450W', '80+ Bronze'],
      case: ['Micro ATX', 'SFF'],
      cooler: ['Stock Cooler']
    }
  },
  {
    id: 'office-budget',
    name: 'Basic Office',
    description: 'Web browsing, documents, email, basic tasks',
    budget: '৳25,000 - ৳40,000',
    category: 'office',
    icon: '📝',
    targetSpecs: {
      cpuCores: 4,
      ramCapacityGB: 8,
      storageGB: 256,
      psuWattage: 400
    },
    recommendations: {
      cpu: ['AMD Ryzen 3', 'Intel Core i3', 'Pentium'],
      motherboard: ['A520', 'H610'],
      ram: ['DDR4', '8GB'],
      gpu: [], // Integrated graphics only
      storage: ['256GB SSD', '500GB HDD'],
      psu: ['400W', '80+ Bronze'],
      case: ['Micro ATX', 'Mini ITX'],
      cooler: ['Stock Cooler']
    }
  }
];

export function getTemplatesByCategory(category: BuildTemplate['category']): BuildTemplate[] {
  return buildTemplates.filter(t => t.category === category);
}

export function getTemplateById(id: string): BuildTemplate | undefined {
  return buildTemplates.find(t => t.id === id);
}

export function matchComponentToTemplate(
  component: Component,
  template: BuildTemplate,
  category: keyof BuildTemplate['recommendations']
): number {
  let score = 0;
  const recommendations = template.recommendations[category];
  
  if (!recommendations || recommendations.length === 0) return 0;
  
  // Check if component name/brand matches any recommendation
  const componentText = `${component.brand || ''} ${component.name}`.toLowerCase();
  
  for (const rec of recommendations) {
    if (componentText.includes(rec.toLowerCase())) {
      score += 10;
    }
  }
  
  // Additional scoring based on specs (if available)
  if (component.specs && typeof component.specs === 'object') {
    const specs = component.specs as Record<string, unknown>;
    
    // RAM capacity matching
    if (category === 'ram' && template.targetSpecs.ramCapacityGB) {
      const capacity = Number(specs.capacity_gb) || 0;
      if (capacity >= template.targetSpecs.ramCapacityGB) {
        score += 5;
      }
    }

    // Storage capacity matching
    if (category === 'storage' && template.targetSpecs.storageGB) {
      const capacity = Number(specs.capacity) || 0;
      if (capacity >= template.targetSpecs.storageGB) {
        score += 5;
      }
    }

    // PSU wattage matching
    if (category === 'psu' && template.targetSpecs.psuWattage) {
      const wattage = Number(specs.wattage) || parseInt(component.name.match(/(\d{3,4})\s*W/i)?.[1] || '0');
      if (wattage >= template.targetSpecs.psuWattage) {
        score += 5;
      }
    }
  }
  
  return score;
}

export function getSuggestedComponents(
  components: Component[],
  template: BuildTemplate,
  category: keyof BuildTemplate['recommendations']
): Component[] {
  // Score all components and sort by score
  const scored = components.map(comp => ({
    component: comp,
    score: matchComponentToTemplate(comp, template, category)
  }));
  
  // Sort by score descending, then by price ascending
  scored.sort((a, b) => {
    if (b.score !== a.score) return b.score - a.score;
    
    const priceA = a.component.lowest_price_bdt ? 
      (typeof a.component.lowest_price_bdt === 'string' ? parseFloat(a.component.lowest_price_bdt) : a.component.lowest_price_bdt) : 
      Infinity;
    const priceB = b.component.lowest_price_bdt ? 
      (typeof b.component.lowest_price_bdt === 'string' ? parseFloat(b.component.lowest_price_bdt) : b.component.lowest_price_bdt) : 
      Infinity;
    
    return priceA - priceB;
  });
  
  // Return top 10 components with score > 0
  return scored
    .filter(s => s.score > 0)
    .slice(0, 10)
    .map(s => s.component);
}
