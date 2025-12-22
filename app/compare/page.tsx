'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { Plus, X, ArrowLeft, Search, RefreshCw } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { ApiClient, Component } from '@/lib/api';
import { formatPriceUSD, formatPriceBDT, USD_TO_BDT_RATE } from '@/lib/currency';

const api = new ApiClient(process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8000/api/v1');

interface ComparisonSlot {
  component: Component | null;
}

export default function ComparisonPage() {
  const [selectedCategory, setSelectedCategory] = useState<string>('cpu');
  const [comparisonSlots, setComparisonSlots] = useState<(Component | null)[]>([null, null, null]);
  const [availableComponents, setAvailableComponents] = useState<Component[]>([]);
  const [loading, setLoading] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedSlotIndex, setSelectedSlotIndex] = useState<number | null>(null);
  const [showUSD, setShowUSD] = useState(false);

  useEffect(() => {
    fetchComponents();
  }, [selectedCategory]);

  const fetchComponents = async () => {
    setLoading(true);
    try {
      const response = await api.getComponents({ category: selectedCategory, per_page: 50 });
      setAvailableComponents(response.data);
    } catch (error) {
      console.error('Failed to fetch components:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSelectComponent = (component: Component, slotIndex: number) => {
    const newSlots = [...comparisonSlots];
    newSlots[slotIndex] = component;
    setComparisonSlots(newSlots);
    setSelectedSlotIndex(null);
    setSearchQuery('');
  };

  const handleRemoveComponent = (slotIndex: number) => {
    const newSlots = [...comparisonSlots];
    newSlots[slotIndex] = null;
    setComparisonSlots(newSlots);
  };

  const filteredComponents = availableComponents.filter(comp => {
    const brandName = comp.brand ? (typeof comp.brand === 'string' ? comp.brand : comp.brand_obj?.brand_name || '') : '';
    return comp.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
           brandName.toLowerCase().includes(searchQuery.toLowerCase());
  });

  const categories = [
    { value: 'cpu', label: 'Processors (CPU)' },
    { value: 'video_card', label: 'Graphics Cards (GPU)' },
    { value: 'motherboard', label: 'Motherboards' },
    { value: 'memory', label: 'Memory (RAM)' },
    { value: 'internal_hard_drive', label: 'Storage Drives' },
    { value: 'power_supply', label: 'Power Supplies' },
    { value: 'case', label: 'Cases' },
    { value: 'cpu_cooler', label: 'CPU Coolers' },
  ];

  const handleAddSlot = () => {
    if (comparisonSlots.length < 4) {
      setComparisonSlots([...comparisonSlots, null]);
    }
  };

  const handleRemoveSlot = (index: number) => {
    if (comparisonSlots.length > 2) {
      setComparisonSlots(comparisonSlots.filter((_, i) => i !== index));
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Breadcrumb */}
        <div className="flex items-center gap-2 text-sm text-muted-foreground mb-6">
          <Link href="/" className="hover:text-primary">Home</Link>
          <span>/</span>
          <span className="text-foreground">Compare Components</span>
        </div>

        {/* Back Button */}
        <Button variant="ghost" asChild className="mb-6">
          <Link href="/components">
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back to Components
          </Link>
        </Button>

        {/* Page Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold mb-4">Compare Components</h1>
          <p className="text-muted-foreground mb-6">
            Select a component category and add items to compare their specifications side by side
          </p>

          {/* Category Selection */}
          <div className="flex items-center gap-4">
            <label className="text-sm font-medium">Component Type:</label>
            <Select value={selectedCategory} onValueChange={setSelectedCategory}>
              <SelectTrigger className="w-64">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {categories.map((cat) => (
                  <SelectItem key={cat.value} value={cat.value}>
                    {cat.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </div>

        {/* Comparison Slots */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-6">
          {comparisonSlots.map((component, index) => (
            <Card key={index} className="relative">
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-base">Component {index + 1}</CardTitle>
                <div className="flex gap-2">
                  {component && (
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-8 w-8"
                      onClick={() => handleRemoveComponent(index)}
                    >
                      <X className="h-4 w-4" />
                    </Button>
                  )}
                </div>
              </CardHeader>
              <CardContent>
                {component ? (
                  <>
                    <div className="aspect-square bg-gray-100 rounded-lg mb-4 flex items-center justify-center overflow-hidden relative">
                      {component.primary_image_url || component.image_urls?.[0] ? (
                        <Image
                          src={(component.primary_image_url || component.image_urls?.[0]) as string}
                          alt={component.name}
                          fill
                          className="object-cover"
                          unoptimized
                        />
                      ) : (
                        <span className="text-4xl">
                          {selectedCategory === 'cpu' && '🖥️'}
                          {selectedCategory === 'motherboard' && '🔲'}
                          {selectedCategory === 'video_card' && '🎮'}
                          {selectedCategory === 'memory' && '💾'}
                          {selectedCategory === 'internal_hard_drive' && '💿'}
                          {selectedCategory === 'power_supply' && '⚡'}
                          {selectedCategory === 'case' && '🖼️'}
                          {selectedCategory === 'cpu_cooler' && '❄️'}
                        </span>
                      )}
                    </div>
                    <div className="space-y-2">
                      {component.brand && (
                        <Badge variant="secondary" className="mb-1">
                          {typeof component.brand === 'string' ? component.brand : component.brand_obj?.brand_name}
                        </Badge>
                      )}
                      <h3 className="font-semibold text-sm line-clamp-2">{component.name}</h3>
                      <div className="text-lg font-bold text-primary">
                        {showUSD ? formatPriceUSD(component.lowest_price_usd) : formatPriceBDT(component.lowest_price_usd ? component.lowest_price_usd * USD_TO_BDT_RATE : null)}
                      </div>
                    </div>
                  </>
                ) : (
                  <>
                    <div className="aspect-square bg-gray-100 rounded-lg mb-4 flex items-center justify-center">
                      <span className="text-4xl text-gray-400">?</span>
                    </div>
                    <Button 
                      variant="outline" 
                      className="w-full"
                      onClick={() => setSelectedSlotIndex(index)}
                    >
                      <Plus className="h-4 w-4 mr-2" />
                      Select Component
                    </Button>
                  </>
                )}
              </CardContent>
            </Card>
          ))}

          {/* Add Slot Button */}
          {comparisonSlots.length < 4 && (
            <Card className="border-dashed cursor-pointer hover:bg-gray-50 transition-colors" onClick={handleAddSlot}>
              <CardContent className="flex items-center justify-center h-full min-h-[400px]">
                <div className="text-center">
                  <Plus className="h-12 w-12 text-muted-foreground mx-auto mb-3" />
                  <p className="text-sm font-medium">Add Another Component</p>
                  <p className="text-xs text-muted-foreground mt-1">Compare up to 4 items</p>
                </div>
              </CardContent>
            </Card>
          )}
        </div>

        {/* Component Selection Modal */}
        {selectedSlotIndex !== null && (
          <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
            <Card className="w-full max-w-3xl max-h-[80vh] overflow-hidden">
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle>Select a Component</CardTitle>
                  <Button variant="ghost" size="icon" onClick={() => setSelectedSlotIndex(null)}>
                    <X className="h-4 w-4" />
                  </Button>
                </div>
                <div className="relative mt-4">
                  <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                  <Input
                    placeholder="Search components..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="pl-10"
                  />
                </div>
              </CardHeader>
              <CardContent className="overflow-y-auto max-h-[50vh]">
                {loading ? (
                  <div className="text-center py-8">Loading components...</div>
                ) : filteredComponents.length > 0 ? (
                  <div className="space-y-2">
                    {filteredComponents.map((comp) => (
                      <div
                        key={comp.id}
                        className="flex items-center justify-between p-3 border rounded-lg hover:bg-accent cursor-pointer"
                        onClick={() => handleSelectComponent(comp, selectedSlotIndex)}
                      >
                        <div className="flex-1">
                          {comp.brand && (
                            <Badge variant="outline" className="mb-1">
                              {typeof comp.brand === 'string' ? comp.brand : comp.brand_obj?.brand_name}
                            </Badge>
                          )}
                          <div className="font-medium text-sm">{comp.name}</div>
                        </div>
                        <div className="text-right">
                          <div className="font-bold text-primary">
                            {formatPriceBDT(comp.lowest_price_usd ? comp.lowest_price_usd * USD_TO_BDT_RATE : null)}
                          </div>
                          <div className="text-xs text-muted-foreground">
                            {formatPriceUSD(comp.lowest_price_usd)}
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8 text-muted-foreground">
                    No components found
                  </div>
                )}
              </CardContent>
            </Card>
          </div>
        )}

        {/* Price Toggle */}
        <div className="flex justify-end mb-4">
          <Button 
            variant="outline" 
            size="sm"
            onClick={() => setShowUSD(!showUSD)}
          >
            <RefreshCw className="h-3 w-3 mr-2" />
            {showUSD ? 'Show BDT' : 'Show USD'}
          </Button>
        </div>

        {/* Comparison Table */}
        {comparisonSlots.some(c => c !== null) && (
          <Card className="mb-6">
            <CardHeader>
              <CardTitle>Specifications Comparison</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead>
                    <tr className="border-b">
                      <th className="text-left p-3 font-medium">Specification</th>
                      {comparisonSlots.map((comp, idx) => (
                        <th key={idx} className="text-left p-3 font-medium">
                          {comp ? comp.name.substring(0, 30) + '...' : 'Empty'}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    <tr className="border-b">
                      <td className="p-3 text-sm font-medium">Brand</td>
                      {comparisonSlots.map((comp, idx) => {
                        const brand = comp?.brand ? (typeof comp.brand === 'string' ? comp.brand : comp.brand_obj?.brand_name) : undefined;
                        return <td key={idx} className="p-3 text-sm">{brand || '-'}</td>;
                      })}
                    </tr>
                    <tr className="border-b">
                      <td className="p-3 text-sm font-medium">Model</td>
                      {comparisonSlots.map((comp, idx) => (
                        <td key={idx} className="p-3 text-sm">
                          {comp?.model || '-'}
                        </td>
                      ))}
                    </tr>
                    <tr className="border-b">
                      <td className="p-3 text-sm font-medium">Price (BDT)</td>
                      {comparisonSlots.map((comp, idx) => (
                        <td key={idx} className="p-3 text-sm font-semibold">
                          {comp ? formatPriceBDT(comp.lowest_price_usd ? comp.lowest_price_usd * USD_TO_BDT_RATE : null) : '-'}
                        </td>
                      ))}
                    </tr>
                    <tr className="border-b">
                      <td className="p-3 text-sm font-medium">Price (USD)</td>
                      {comparisonSlots.map((comp, idx) => (
                        <td key={idx} className="p-3 text-sm text-muted-foreground">
                          {comp ? formatPriceUSD(comp.lowest_price_usd) : '-'}
                        </td>
                      ))}
                    </tr>
                  </tbody>
                </table>
              </div>
              <p className="text-xs text-muted-foreground mt-4">
                *Prices converted at 1 USD = {USD_TO_BDT_RATE} BDT (approx.)
              </p>
            </CardContent>
          </Card>
        )}

        {/* Comparison Table Placeholder */}
        {!comparisonSlots.some(c => c !== null) && (
          <Card>
            <CardHeader>
              <CardTitle>Specifications Comparison</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-center py-12 text-muted-foreground">
                <p className="mb-2">Select components to see detailed specifications comparison</p>
                <p className="text-sm">
                  Choose {comparisonSlots.length} {categories.find(c => c.value === selectedCategory)?.label} to compare
                </p>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Call to Action */}
        <Card className="mt-8 bg-primary/5 border-primary/20">
          <CardContent className="py-8 text-center">
            <h3 className="text-xl font-bold mb-2">Need Help Choosing?</h3>
            <p className="text-muted-foreground mb-4">
              Use our PC Builder tool to get automatic compatibility checking and recommendations
            </p>
            <Button asChild>
              <Link href="/builder">Open PC Builder</Link>
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
