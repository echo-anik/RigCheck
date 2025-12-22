import Link from 'next/link';
import Image from 'next/image';
import { Card, CardContent, CardFooter } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import type { Component } from '@/lib/api';

interface ComponentCardProps {
  component: Component;
}

export function ComponentCard({ component }: ComponentCardProps) {
  // Format price in BDT
  const formatPrice = (price: number | string | null | undefined) => {
    if (!price) return 'Price not available';
    const numPrice = typeof price === 'string' ? parseFloat(price) : price;
    return `৳${numPrice.toLocaleString('en-BD')}`;
  };

  // Extract key specs based on category
  const getKeySpecs = () => {
    const specs = component.specs;
    if (!specs || typeof specs !== 'object') return [];
    
    // Get important specs based on category
    const specList: string[] = [];
    
    switch (component.category) {
      case 'cpu':
        if (specs.core_count) specList.push(`${specs.core_count} Cores`);
        if (specs.core_clock) specList.push(`${specs.core_clock} GHz`);
        if (specs.socket) specList.push(`Socket: ${specs.socket}`);
        break;
      case 'motherboard':
        if (specs.socket) specList.push(`Socket: ${String(specs.socket)}`);
        if (specs.form_factor) specList.push(String(specs.form_factor));
        if (specs.chipset) specList.push(`Chipset: ${String(specs.chipset)}`);
        break;
      case 'gpu':
        if (specs.chipset) specList.push(String(specs.chipset));
        if (specs.memory_gb) specList.push(`${specs.memory_gb} GB`);
        if (specs.boost_clock) specList.push(`${specs.boost_clock} MHz`);
        break;
      case 'memory':
      case 'ram':
        if (specs.capacity_gb) specList.push(`${specs.capacity_gb} GB`);
        if (specs.speed_mhz) specList.push(`${specs.speed_mhz} MHz`);
        if (specs.ddr_generation) specList.push(String(specs.ddr_generation));
        break;
      case 'internal-hard-drive':
      case 'storage':
        if (specs.capacity_gb) specList.push(`${specs.capacity_gb} GB`);
        if (specs.type) specList.push(String(specs.type));
        if (specs.interface) specList.push(String(specs.interface));
        break;
      case 'power-supply':
      case 'psu':
        if (specs.wattage) specList.push(`${specs.wattage}W`);
        if (specs.efficiency) specList.push(String(specs.efficiency));
        if (specs.modular) specList.push(String(specs.modular));
        break;
      case 'case':
        if (specs.form_factor) specList.push(String(specs.form_factor));
        if (specs.color) specList.push(String(specs.color));
        break;
      case 'cpu-cooler':
      case 'cooler':
        if (specs.fan_rpm) specList.push(`${specs.fan_rpm} RPM`);
        if (specs.noise_level) specList.push(`${specs.noise_level} dB`);
        if (specs.radiator_size) specList.push(String(specs.radiator_size));
        break;
      default:
        // For other categories, show first 3 key-value pairs
        Object.entries(specs).slice(0, 3).forEach(([key, value]) => {
          if (value && typeof value !== 'object') {
            specList.push(`${key}: ${value}`);
          }
        });
    }
    
    return specList.slice(0, 3);
  };

  const keySpecs = getKeySpecs();

  return (
    <Card className="group hover:shadow-lg transition-shadow h-full flex flex-col">
      <Link href={`/components/${component.product_id}`} className="flex-1 flex flex-col">
        <CardContent className="p-4 flex-1 flex flex-col">
          {/* Product Image */}
          <div className="aspect-square bg-gray-100 rounded-md mb-4 flex items-center justify-center overflow-hidden relative">
            {component.primary_image_url || component.image_urls?.[0] ? (
              <Image
                src={(component.primary_image_url || component.image_urls?.[0]) as string}
                alt={component.name}
                fill
                className="object-cover"
                unoptimized
              />
            ) : (
              <div className="text-gray-400 text-center">
                <div className="text-4xl mb-2">
                  {component.category === 'cpu' && '🖥️'}
                  {component.category === 'motherboard' && '🔲'}
                  {component.category === 'gpu' && '🎮'}
                  {component.category === 'ram' && '💾'}
                  {component.category === 'storage' && '💿'}
                  {component.category === 'psu' && '⚡'}
                  {component.category === 'case' && '🖼️'}
                  {component.category === 'cooler' && '❄️'}
                </div>
                <p className="text-xs px-2">No Image</p>
              </div>
            )}
          </div>

          {/* Brand Badge */}
          {component.brand && (
            <Badge variant="secondary" className="mb-2 w-fit">
              {typeof component.brand === 'string' ? component.brand : component.brand_obj?.brand_name}
            </Badge>
          )}

          {/* Component Name */}
          <h3 className="font-semibold text-sm mb-2 line-clamp-2 group-hover:text-primary transition-colors">
            {component.name}
          </h3>

          {/* Key Specs */}
          {keySpecs.length > 0 && (
            <div className="text-xs text-muted-foreground space-y-1 mb-3">
              {keySpecs.map((spec: string | undefined, idx: number) => (
                <div key={idx} className="line-clamp-1">• {spec}</div>
              ))}
            </div>
          )}
        </CardContent>

        <CardFooter className="p-4 pt-0 flex items-center justify-between mt-auto">
          <div className="font-bold text-lg text-primary">
            {formatPrice(component.lowest_price_bdt)}
          </div>
          <Button size="sm" variant="outline" className="group-hover:bg-primary group-hover:text-primary-foreground transition-colors">
            View
          </Button>
        </CardFooter>
      </Link>
    </Card>
  );
}
