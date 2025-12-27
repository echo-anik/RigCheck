'use client';

import { useState } from 'react';
import { ChevronLeft, ChevronRight, CheckCircle2, AlertCircle, Sparkles } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Progress } from '@/components/ui/progress';
import { Badge } from '@/components/ui/badge';
import { Component } from '@/lib/api';
import { formatPriceBDT, convertBDTtoUSD } from '@/lib/currency';

export interface BuildStep {
  id: string;
  category: string;
  label: string;
  description: string;
  required: boolean;
  icon: string;
}

export const buildSteps: BuildStep[] = [
  {
    id: 'cpu',
    category: 'cpu',
    label: 'Processor',
    description: 'The brain of your PC - choose based on your performance needs',
    required: true,
    icon: '🧠'
  },
  {
    id: 'motherboard',
    category: 'motherboard',
    label: 'Motherboard',
    description: 'Must match your CPU socket and support your components',
    required: true,
    icon: '🔌'
  },
  {
    id: 'ram',
    category: 'ram',
    label: 'RAM (Memory)',
    description: 'Choose capacity and speed compatible with your motherboard',
    required: true,
    icon: '💾'
  },
  {
    id: 'gpu',
    category: 'gpu',
    label: 'Graphics Card',
    description: 'Essential for gaming and content creation',
    required: false,
    icon: '🎮'
  },
  {
    id: 'storage',
    category: 'storage',
    label: 'Storage',
    description: 'SSD recommended for OS, add HDD for mass storage',
    required: true,
    icon: '💽'
  },
  {
    id: 'psu',
    category: 'psu',
    label: 'Power Supply',
    description: 'Ensure sufficient wattage for all components',
    required: true,
    icon: '⚡'
  },
  {
    id: 'case',
    category: 'case',
    label: 'Case',
    description: 'Pick a size that fits your motherboard and GPU',
    required: true,
    icon: '📦'
  },
  {
    id: 'cooler',
    category: 'cooler',
    label: 'CPU Cooler',
    description: 'Better cooling for overclocking and quieter operation',
    required: false,
    icon: '❄️'
  }
];

interface BuildWizardProps {
  availableComponents: Record<string, Component[]>;
  selectedComponents: Record<string, Component | null>;
  onComponentSelect: (category: string, component: Component) => void;
  onComponentRemove: (category: string) => void;
  compatibilityCheck: {
    category: string;
    status: 'idle' | 'checking' | 'compatible' | 'warning' | 'error';
    message?: string;
  } | null;
  compatibilityHints?: Record<string, string | undefined>;
}

export function BuildWizard({
  availableComponents,
  selectedComponents,
  onComponentSelect,
  onComponentRemove,
  compatibilityCheck,
  compatibilityHints
}: BuildWizardProps) {
  const [currentStep, setCurrentStep] = useState(0);
  const [searchQuery, setSearchQuery] = useState('');
  const [filterBrand, setFilterBrand] = useState<string>('all');

  const currentStepInfo = buildSteps[currentStep];
  const progress = ((currentStep + 1) / buildSteps.length) * 100;

  // Get available brands for current category
  const availableBrands = currentStepInfo
    ? Array.from(
        new Set(
          (availableComponents[currentStepInfo.category] || [])
            .map(c => c.brand)
            .filter(Boolean)
        )
      ).sort()
    : [];

  // Filter components based on search and brand
  const filteredComponents = currentStepInfo
    ? (availableComponents[currentStepInfo.category] || []).filter(comp => {
        const matchesSearch =
          comp.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
          comp.brand?.toLowerCase().includes(searchQuery.toLowerCase());
        const matchesBrand = filterBrand === 'all' || comp.brand === filterBrand;
        return matchesSearch && matchesBrand;
      })
    : [];

  const handleNext = () => {
    if (currentStep < buildSteps.length - 1) {
      setCurrentStep(currentStep + 1);
      setSearchQuery('');
      setFilterBrand('all');
    }
  };

  const handlePrevious = () => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
      setSearchQuery('');
      setFilterBrand('all');
    }
  };

  const handleComponentClick = (component: Component) => {
    onComponentSelect(currentStepInfo.category, component);
  };

  const isStepComplete = (stepIndex: number): boolean => {
    const step = buildSteps[stepIndex];
    return selectedComponents[step.category] !== null;
  };

  const canProceed = (): boolean => {
    return !currentStepInfo.required || isStepComplete(currentStep);
  };

  const formatPrice = (price: number | string) => {
    const numPrice = typeof price === 'string' ? parseFloat(price) : price;
    const usd = convertBDTtoUSD(numPrice);
    return `${formatPriceBDT(numPrice)} (~$${(usd || 0).toFixed(0)})`;
  };

  return (
    <div className="space-y-6">
      {/* Progress Bar */}
      <div className="space-y-2">
        <div className="flex items-center justify-between text-sm">
          <span className="font-medium">
            Step {currentStep + 1} of {buildSteps.length}
          </span>
          <span className="text-muted-foreground">
            {Math.round(progress)}% Complete
          </span>
        </div>
        <Progress value={progress} className="h-2" />
      </div>

      {/* Step Indicators */}
      <div className="grid grid-cols-4 md:grid-cols-8 gap-2">
        {buildSteps.map((step, index) => (
          <button
            key={step.id}
            onClick={() => {
              setCurrentStep(index);
              setSearchQuery('');
              setFilterBrand('all');
            }}
            className={`p-2 rounded-lg border-2 transition-all ${
              index === currentStep
                ? 'border-primary bg-primary/10'
                : isStepComplete(index)
                ? 'border-green-500 bg-green-50'
                : 'border-gray-200 hover:border-gray-300'
            }`}
          >
            <div className="text-2xl mb-1">{step.icon}</div>
            <div className="text-xs font-medium truncate">{step.label}</div>
            {isStepComplete(index) && (
              <CheckCircle2 className="h-3 w-3 mx-auto mt-1 text-green-600" />
            )}
          </button>
        ))}
      </div>

      {/* Current Step Content */}
      <Card className="border-2 border-primary">
        <CardContent className="p-6">
          <div className="flex items-start justify-between mb-4">
            <div>
              <div className="flex items-center gap-2">
                <span className="text-3xl">{currentStepInfo.icon}</span>
                <div>
                  <h2 className="text-2xl font-bold">{currentStepInfo.label}</h2>
                  {currentStepInfo.required && (
                    <Badge variant="destructive" className="mt-1">Required</Badge>
                  )}
                </div>
              </div>
              <p className="text-muted-foreground mt-2">
                {currentStepInfo.description}
              </p>
            </div>
          </div>

          {/* Compatibility Status */}
          {compatibilityCheck && compatibilityCheck.category === currentStepInfo.category && (
            <div className={`flex items-center gap-2 p-3 rounded-lg mb-4 ${
              compatibilityCheck.status === 'compatible' ? 'bg-green-50 text-green-700' :
              compatibilityCheck.status === 'warning' ? 'bg-yellow-50 text-yellow-700' :
              compatibilityCheck.status === 'error' ? 'bg-red-50 text-red-700' :
              'bg-blue-50 text-blue-700'
            }`}>
              {compatibilityCheck.status === 'checking' ? (
                <>
                  <div className="animate-spin h-4 w-4 border-2 border-current border-t-transparent rounded-full" />
                  <span className="text-sm font-medium">Checking compatibility...</span>
                </>
              ) : compatibilityCheck.status === 'compatible' ? (
                <>
                  <CheckCircle2 className="h-4 w-4" />
                  <span className="text-sm font-medium">{compatibilityCheck.message || 'Compatible!'}</span>
                </>
              ) : compatibilityCheck.status === 'error' ? (
                <>
                  <AlertCircle className="h-4 w-4" />
                  <span className="text-sm font-medium">{compatibilityCheck.message || 'Incompatible'}</span>
                </>
              ) : compatibilityCheck.status === 'warning' ? (
                <>
                  <AlertCircle className="h-4 w-4" />
                  <span className="text-sm font-medium">{compatibilityCheck.message}</span>
                </>
              ) : null}
            </div>
          )}

          {/* Compatibility hint (e.g., socket filtering) */}
          {compatibilityHints?.[currentStepInfo.category] && (
            <div className="flex items-start gap-2 p-3 rounded-lg mb-4 bg-blue-50 text-blue-800">
              <AlertCircle className="h-4 w-4 mt-0.5" />
              <p className="text-sm leading-snug">{compatibilityHints[currentStepInfo.category]}</p>
            </div>
          )}

          {/* Currently Selected Component */}
          {selectedComponents[currentStepInfo.category] && (
            <div className="bg-green-50 border-2 border-green-500 rounded-lg p-4 mb-4">
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-medium text-green-700 flex items-center gap-2">
                  <CheckCircle2 className="h-4 w-4" />
                  Selected Component
                </span>
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => onComponentRemove(currentStepInfo.category)}
                  className="text-green-700 hover:text-green-800"
                >
                  Change
                </Button>
              </div>
              <div className="flex items-center gap-3">
                <div className="w-16 h-16 bg-white rounded-lg overflow-hidden flex-shrink-0">
                  {selectedComponents[currentStepInfo.category]!.image_urls?.[0] ? (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img
                      src={selectedComponents[currentStepInfo.category]!.image_urls![0]}
                      alt={selectedComponents[currentStepInfo.category]!.name}
                      className="w-full h-full object-contain p-2"
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center text-gray-400 text-xs">
                      No Image
                    </div>
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="font-medium text-sm line-clamp-2">
                    {selectedComponents[currentStepInfo.category]!.name}
                  </div>
                  {selectedComponents[currentStepInfo.category]!.brand && (
                    <Badge variant="outline" className="mt-1 text-xs">
                      {selectedComponents[currentStepInfo.category]!.brand}
                    </Badge>
                  )}
                  <div className="font-bold text-green-700 mt-1">
                    {selectedComponents[currentStepInfo.category]!.lowest_price_bdt
                      ? formatPrice(selectedComponents[currentStepInfo.category]!.lowest_price_bdt!)
                      : 'N/A'}
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Filter Controls */}
          <div className="flex flex-col sm:flex-row gap-3 mb-4">
            <input
              type="text"
              placeholder="Search components..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="flex-1 px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
            />
            <select
              value={filterBrand}
              onChange={(e) => setFilterBrand(e.target.value)}
              className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              aria-label="Filter by brand"
            >
              <option value="all">All Brands</option>
              {availableBrands.map(brand => (
                <option key={brand} value={brand}>{brand}</option>
              ))}
            </select>
          </div>

          {/* Component List */}
          <div className="max-h-[50vh] overflow-y-auto space-y-2">
            {filteredComponents.length > 0 ? (
              filteredComponents.slice(0, 50).map((component) => (
                <div
                  key={component.id}
                  onClick={() => handleComponentClick(component)}
                  className={`border-2 rounded-lg p-3 cursor-pointer transition-all hover:shadow-md hover:border-primary ${
                    selectedComponents[currentStepInfo.category]?.id === component.id
                      ? 'border-green-500 bg-green-50'
                      : 'border-gray-200'
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <div className="w-16 h-16 bg-gray-50 rounded-lg overflow-hidden flex-shrink-0">
                      {component.image_urls?.[0] ? (
                        // eslint-disable-next-line @next/next/no-img-element
                        <img
                          src={component.image_urls[0]}
                          alt={component.name}
                          className="w-full h-full object-contain p-2"
                        />
                      ) : (
                        <div className="w-full h-full flex items-center justify-center text-gray-400 text-xs">
                          No Image
                        </div>
                      )}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="font-medium text-sm line-clamp-2">
                        {component.name}
                      </div>
                      {component.brand && (
                        <Badge variant="outline" className="mt-1 text-xs">
                          {component.brand}
                        </Badge>
                      )}
                      <div className="font-bold text-primary mt-1">
                        {component.lowest_price_bdt
                          ? formatPrice(component.lowest_price_bdt)
                          : 'N/A'}
                      </div>
                    </div>
                    <Button size="sm" className="flex-shrink-0">
                      Select
                    </Button>
                  </div>
                </div>
              ))
            ) : (
              <div className="text-center py-12 text-muted-foreground">
                <p>No components found</p>
                <p className="text-sm mt-1">Try adjusting your search or filters</p>
              </div>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Navigation Buttons */}
      <div className="flex items-center justify-between gap-4">
        <Button
          variant="outline"
          onClick={handlePrevious}
          disabled={currentStep === 0}
          className="flex-1"
        >
          <ChevronLeft className="h-4 w-4 mr-2" />
          Previous
        </Button>

        {currentStep < buildSteps.length - 1 ? (
          <Button
            onClick={handleNext}
            disabled={!canProceed()}
            className="flex-1"
          >
            Next
            <ChevronRight className="h-4 w-4 ml-2" />
          </Button>
        ) : (
          <Button
            onClick={handleNext}
            disabled={!canProceed()}
            className="flex-1 bg-green-600 hover:bg-green-700"
          >
            <Sparkles className="h-4 w-4 mr-2" />
            Complete Build
          </Button>
        )}
      </div>

      {/* Skip Optional Step */}
      {!currentStepInfo.required && !selectedComponents[currentStepInfo.category] && (
        <Button
          variant="ghost"
          onClick={handleNext}
          className="w-full"
        >
          Skip Optional Component
        </Button>
      )}
    </div>
  );
}
