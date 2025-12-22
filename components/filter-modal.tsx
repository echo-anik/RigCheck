'use client';

import { X, SlidersHorizontal } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Checkbox } from '@/components/ui/checkbox';
import { Label } from '@/components/ui/label';

interface FilterModalProps {
  isOpen: boolean;
  onClose: () => void;
  filters: {
    priceMin: string;
    priceMax: string;
    brands: string[];
    inStock: boolean;
    featured: boolean;
  };
  onFilterChange: (filters: {
    priceMin: string;
    priceMax: string;
    brands: string[];
    inStock: boolean;
    featured: boolean;
  }) => void;
  availableBrands: string[];
}

export function FilterModal({
  isOpen,
  onClose,
  filters,
  onFilterChange,
  availableBrands,
}: FilterModalProps) {
  if (!isOpen) return null;

  const handleBrandToggle = (brand: string) => {
    const newBrands = filters.brands.includes(brand)
      ? filters.brands.filter((b) => b !== brand)
      : [...filters.brands, brand];
    onFilterChange({ ...filters, brands: newBrands });
  };

  const handleReset = () => {
    onFilterChange({
      priceMin: '',
      priceMax: '',
      brands: [],
      inStock: false,
      featured: false,
    });
  };

  const handleApply = () => {
    onClose();
  };

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <Card className="w-full max-w-2xl max-h-[90vh] overflow-y-auto relative">
        <Button
          variant="ghost"
          size="icon"
          className="absolute right-2 top-2"
          onClick={onClose}
        >
          <X className="h-4 w-4" />
        </Button>

        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <SlidersHorizontal className="h-5 w-5" />
            Advanced Filters
          </CardTitle>
        </CardHeader>

        <CardContent className="space-y-6">
          {/* Price Range */}
          <div>
            <h3 className="font-semibold mb-3">Price Range (BDT)</h3>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label htmlFor="priceMin">Minimum</Label>
                <Input
                  id="priceMin"
                  type="number"
                  placeholder="0"
                  value={filters.priceMin}
                  onChange={(e) =>
                    onFilterChange({ ...filters, priceMin: e.target.value })
                  }
                />
              </div>
              <div>
                <Label htmlFor="priceMax">Maximum</Label>
                <Input
                  id="priceMax"
                  type="number"
                  placeholder="999999"
                  value={filters.priceMax}
                  onChange={(e) =>
                    onFilterChange({ ...filters, priceMax: e.target.value })
                  }
                />
              </div>
            </div>
          </div>

          {/* Brands */}
          <div>
            <h3 className="font-semibold mb-3">Brands</h3>
            <div className="grid grid-cols-2 gap-3 max-h-48 overflow-y-auto p-2 border rounded-lg">
              {availableBrands.map((brand) => (
                <div key={brand} className="flex items-center space-x-2">
                  <Checkbox
                    id={`brand-${brand}`}
                    checked={filters.brands.includes(brand)}
                    onCheckedChange={() => handleBrandToggle(brand)}
                  />
                  <Label
                    htmlFor={`brand-${brand}`}
                    className="text-sm cursor-pointer"
                  >
                    {brand}
                  </Label>
                </div>
              ))}
            </div>
          </div>

          {/* Availability */}
          <div>
            <h3 className="font-semibold mb-3">Availability</h3>
            <div className="space-y-2">
              <div className="flex items-center space-x-2">
                <Checkbox
                  id="inStock"
                  checked={filters.inStock}
                  onCheckedChange={(checked) =>
                    onFilterChange({ ...filters, inStock: !!checked })
                  }
                />
                <Label htmlFor="inStock" className="cursor-pointer">
                  In Stock Only
                </Label>
              </div>
              <div className="flex items-center space-x-2">
                <Checkbox
                  id="featured"
                  checked={filters.featured}
                  onCheckedChange={(checked) =>
                    onFilterChange({ ...filters, featured: !!checked })
                  }
                />
                <Label htmlFor="featured" className="cursor-pointer">
                  Featured Products
                </Label>
              </div>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex gap-3 pt-4 border-t">
            <Button variant="outline" onClick={handleReset} className="flex-1">
              Reset All
            </Button>
            <Button onClick={handleApply} className="flex-1">
              Apply Filters
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
