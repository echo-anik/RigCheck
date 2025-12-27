'use client';

import { useState } from 'react';
import { CheckCircle2, AlertCircle, AlertTriangle, Save, Share2, Download, Edit2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Component } from '@/lib/api';
import { formatPriceBDT, convertBDTtoUSD } from '@/lib/currency';
import { buildSteps } from './BuildWizard';
import { ShareBuildDialog } from './ShareBuildDialog';
import { exportBuildToPDF, exportBuildToExcel } from '@/lib/export-build';

interface BuildSummaryProps {
  selectedComponents: Record<string, Component | null>;
  buildName: string;
  onBuildNameChange: (name: string) => void;
  onSave: () => void;
  onShare?: () => Promise<{ buildId: string; buildUrl: string } | null>;
  onEdit: (category: string) => void;
  compatibility: {
    is_compatible: boolean;
    warnings: string[];
    errors: string[];
  } | null;
  saving: boolean;
}

export function BuildSummary({
  selectedComponents,
  buildName,
  onBuildNameChange,
  onSave,
  onShare,
  onEdit,
  compatibility,
  saving
}: BuildSummaryProps) {
  const [shareDialogOpen, setShareDialogOpen] = useState(false);
  const [shareData, setShareData] = useState<{ buildId: string; buildUrl: string } | null>(null);
  const [sharing, setSharing] = useState(false);

  const calculateTotalPrice = (): number => {
    return Object.values(selectedComponents).reduce((total, component) => {
      if (component && component.lowest_price_bdt) {
        const price = typeof component.lowest_price_bdt === 'string'
          ? parseFloat(component.lowest_price_bdt)
          : component.lowest_price_bdt;
        return total + price;
      }
      return total;
    }, 0);
  };

  const hasMissingPrices = (): boolean => {
    return Object.values(selectedComponents).some(
      component => component !== null && !component.lowest_price_bdt
    );
  };

  const calculateEstimatedWattage = (): number => {
    let wattage = 0;
    
    // CPU: ~65-125W
    if (selectedComponents['cpu']) {
      wattage += 95;
    }
    
    // GPU: ~150-350W
    if (selectedComponents['gpu']) {
      wattage += 250;
    }
    
    // Motherboard: ~50-80W
    if (selectedComponents['motherboard']) {
      wattage += 65;
    }
    
    // RAM: ~3-5W per stick (assume 2 sticks)
    if (selectedComponents['ram']) {
      wattage += 8;
    }
    
    // Storage: ~2-5W per drive (assume 1 drive)
    if (selectedComponents['storage']) {
      wattage += 5;
    }
    
    // Fans, cooler, peripherals: ~20-30W
    wattage += 25;
    
    return wattage;
  };

  const getPSURecommendation = (): { wattage: number; status: 'good' | 'adequate' | 'insufficient' } => {
    const estimatedWattage = calculateEstimatedWattage();
    const recommendedWattage = Math.ceil(estimatedWattage * 1.3 / 50) * 50; // 30% headroom, round to nearest 50W
    
    const psu = selectedComponents['psu'];
    if (!psu || !psu.specs) {
      return { wattage: recommendedWattage, status: 'adequate' };
    }
    
    // Try to extract PSU wattage from specs or name
    const psuWattage = (psu.specs && typeof psu.specs === 'object' && 'wattage' in psu.specs ? psu.specs.wattage : null) as number | null || 
      parseInt(psu.name.match(/(\d{3,4})\s*W/i)?.[1] || '0');
    
    if (psuWattage && psuWattage >= recommendedWattage) {
      return { wattage: recommendedWattage, status: 'good' };
    } else if (psuWattage && psuWattage >= estimatedWattage) {
      return { wattage: recommendedWattage, status: 'adequate' };
    } else {
      return { wattage: recommendedWattage, status: 'insufficient' };
    }
  };

  const formatPrice = (price: number | string) => {
    const numPrice = typeof price === 'string' ? parseFloat(price) : price;
    const usd = convertBDTtoUSD(numPrice);
    return `${formatPriceBDT(numPrice)} (~$${(usd || 0).toFixed(0)})`;
  };

  const totalPrice = calculateTotalPrice();
  const estimatedWattage = calculateEstimatedWattage();
  const psuRecommendation = getPSURecommendation();
  const selectedCount = Object.values(selectedComponents).filter(c => c !== null).length;
  const requiredCount = buildSteps.filter(s => s.required).length;

  return (
    <div className="space-y-6">
      {/* Build Name */}
      <Card>
        <CardContent className="p-6">
          <label htmlFor="buildName" className="block text-sm font-medium mb-2">
            Build Name
          </label>
          <Input
            id="buildName"
            placeholder="My Awesome Gaming PC"
            value={buildName}
            onChange={(e) => onBuildNameChange(e.target.value)}
            className="text-lg font-medium"
          />
        </CardContent>
      </Card>

      {/* Compatibility Status & System Info - Combined at Top */}
      <div className="grid grid-cols-1 gap-4">
        {/* Compatibility Status */}
        <Card className={
          compatibility?.errors && compatibility.errors.length > 0
            ? 'border-red-500'
            : compatibility?.warnings && compatibility.warnings.length > 0
            ? 'border-yellow-500'
            : compatibility?.is_compatible
            ? 'border-green-500'
            : ''
        }>
          <CardHeader className="pb-3">
            <CardTitle className="flex items-center gap-2 text-base">
              {compatibility?.is_compatible && compatibility.errors.length === 0 ? (
                <>
                  <CheckCircle2 className="h-5 w-5 text-green-600" />
                  <span>Compatible</span>
                </>
              ) : compatibility?.errors && compatibility.errors.length > 0 ? (
                <>
                  <AlertCircle className="h-5 w-5 text-red-600" />
                  <span>Issues Found</span>
                </>
              ) : (
                <>
                  <AlertTriangle className="h-5 w-5 text-yellow-600" />
                  <span>Checking...</span>
                </>
              )}
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-2 pt-0">
            {compatibility?.errors && compatibility.errors.length > 0 && (
              <div className="space-y-2">
                {compatibility.errors.map((error, index) => (
                  <div key={index} className="flex items-start gap-2 text-red-600 text-sm">
                    <AlertCircle className="h-4 w-4 mt-0.5 flex-shrink-0" />
                    <span>{error}</span>
                  </div>
                ))}
              </div>
            )}
            
            {compatibility?.warnings && compatibility.warnings.length > 0 && (
              <div className="space-y-2">
                {compatibility.warnings.map((warning, index) => (
                  <div key={index} className="flex items-start gap-2 text-yellow-600 text-sm">
                    <AlertTriangle className="h-4 w-4 mt-0.5 flex-shrink-0" />
                    <span>{warning}</span>
                  </div>
                ))}
              </div>
            )}
            
            {compatibility?.is_compatible && 
             compatibility.errors.length === 0 && 
             compatibility.warnings.length === 0 && (
              <p className="text-sm text-green-600">
                All components are compatible!
              </p>
            )}
            
            {!compatibility && (
              <p className="text-sm text-muted-foreground">
                Add required components to check
              </p>
            )}
          </CardContent>
        </Card>

        {/* Power Draw - Now at Top */}
        <Card className="border-blue-200 bg-blue-50/50">
          <CardContent className="p-4">
            <div className="flex justify-between items-center mb-2">
              <span className="text-sm font-medium text-blue-900">Power Draw</span>
              <span className="text-2xl font-bold text-blue-700">~{estimatedWattage}W</span>
            </div>
            <div className="flex justify-between items-center text-xs">
              <span className="text-blue-700">Recommended PSU</span>
              <span className={`font-bold ${
                psuRecommendation.status === 'good' ? 'text-green-600' :
                psuRecommendation.status === 'adequate' ? 'text-yellow-600' :
                'text-red-600'
              }`}>
                {psuRecommendation.wattage}W+
                {psuRecommendation.status === 'insufficient' && ' ⚠️'}
              </span>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Component List */}
      <Card>
        <CardHeader>
          <CardTitle>Selected Components ({selectedCount}/{buildSteps.length})</CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          {buildSteps.map((step) => {
            const component = selectedComponents[step.category];
            
            return (
              <div
                key={step.id}
                className={`p-3 rounded-lg border-2 ${
                  component
                    ? 'border-green-500 bg-green-50'
                    : step.required
                    ? 'border-red-200 bg-red-50'
                    : 'border-gray-200 bg-gray-50'
                }`}
              >
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-2">
                    <span className="text-xl">{step.icon}</span>
                    <span className="font-medium text-sm">{step.label}</span>
                    {step.required && !component && (
                      <Badge variant="destructive" className="text-xs">Required</Badge>
                    )}
                  </div>
                  {component && (
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => onEdit(step.category)}
                      className="h-7"
                    >
                      <Edit2 className="h-3 w-3" />
                    </Button>
                  )}
                </div>
                
                {component ? (
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 bg-white rounded overflow-hidden flex-shrink-0">
                      {component.image_urls?.[0] ? (
                        // eslint-disable-next-line @next/next/no-img-element
                        <img
                          src={component.image_urls[0]}
                          alt={component.name}
                          className="w-full h-full object-contain p-1"
                        />
                      ) : (
                        <div className="w-full h-full flex items-center justify-center text-gray-400 text-xs">
                          No Image
                        </div>
                      )}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="text-sm font-medium line-clamp-1">
                        {component.name}
                      </div>
                      <div className="text-sm font-bold text-green-700">
                        {component.lowest_price_bdt
                          ? formatPrice(component.lowest_price_bdt)
                          : 'N/A'}
                      </div>
                    </div>
                  </div>
                ) : (
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => onEdit(step.category)}
                    className="w-full"
                  >
                    Select {step.label}
                  </Button>
                )}
              </div>
            );
          })}
        </CardContent>
      </Card>

      {/* Cost Summary */}
      <Card>
        <CardHeader>
          <CardTitle>Cost Summary</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            {buildSteps.map((step) => {
              const component = selectedComponents[step.category];
              if (!component) return null;
              
              return (
                <div key={step.id} className="flex justify-between text-sm">
                  <span className="text-muted-foreground">{step.label}</span>
                  <span className="font-medium">
                    {component.lowest_price_bdt ? formatPrice(component.lowest_price_bdt) : 'N/A'}
                  </span>
                </div>
              );
            })}
          </div>
          
          <div className="pt-4 border-t">
            <div className="flex justify-between items-center">
              <span className="text-lg font-bold">Total</span>
              <div className="text-right">
                <span className="text-2xl font-bold text-primary">
                  {formatPriceBDT(totalPrice)}
                </span>
                <p className="text-xs text-muted-foreground">
                  ~${(convertBDTtoUSD(totalPrice) || 0).toFixed(0)} USD
                </p>
              </div>
            </div>
          </div>

          {/* Missing Price Warning */}
          {hasMissingPrices() && (
            <div className="bg-red-50 border border-red-200 rounded-lg p-3 mt-3">
              <p className="text-sm text-red-600 font-medium">
                ⚠️ Price Missing
              </p>
              <p className="text-xs text-red-600 mt-1">
                Some components don&apos;t have pricing data. Actual total may be higher.
              </p>
            </div>
          )}

          {/* General Pricing Disclaimer */}
          <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-3 mt-2">
            <p className="text-xs text-yellow-700">
              <strong>Note:</strong> Prices shown may be outdated. Please verify current prices with retailers.
            </p>
          </div>
        </CardContent>
      </Card>

      {/* Build Progress */}
      <Card>
        <CardHeader>
          <CardTitle>Build Progress</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex justify-between text-sm">
            <span className="text-muted-foreground">Required Completed</span>
            <span className={`font-medium ${
              Object.values(selectedComponents).filter((c, i) =>
                c !== null && buildSteps[i].required
              ).length === requiredCount
                ? 'text-green-600'
                : 'text-red-600'
            }`}>
              {Object.values(selectedComponents).filter((c, i) =>
                c !== null && buildSteps[i].required
              ).length} / {requiredCount}
            </span>
          </div>
        </CardContent>
      </Card>

      {/* Action Buttons */}
      <div className="space-y-3">
        <Button
          onClick={onSave}
          disabled={saving || selectedCount === 0 || !buildName.trim()}
          className="w-full"
          size="lg"
        >
          <Save className="h-4 w-4 mr-2" />
          {saving ? 'Saving...' : 'Save Build'}
        </Button>
        
        <div className="grid grid-cols-2 gap-3">
          <Button 
            variant="outline" 
            className="w-full"
            disabled={saving || sharing || selectedCount === 0 || !buildName.trim()}
            onClick={async () => {
              if (onShare) {
                setSharing(true);
                const result = await onShare();
                setSharing(false);
                if (result) {
                  setShareData(result);
                  setShareDialogOpen(true);
                }
              }
            }}
          >
            <Share2 className="h-4 w-4 mr-2" />
            {sharing ? 'Preparing...' : 'Share'}
          </Button>
          <Button 
            variant="outline" 
            className="w-full"
            disabled={selectedCount === 0}
            onClick={() => {
              const exportData = {
                buildName,
                components: buildSteps.map(step => ({
                  category: step.label,
                  component: selectedComponents[step.category]
                })),
                totalPrice: calculateTotalPrice(),
                compatibility
              };
              exportBuildToPDF(exportData);
            }}
          >
            <Download className="h-4 w-4 mr-2" />
            Export
          </Button>
        </div>
      </div>

      {/* Share Dialog */}
      {shareDialogOpen && shareData && (
        <ShareBuildDialog
          buildId={shareData.buildId}
          buildName={buildName}
          buildUrl={shareData.buildUrl}
          onClose={() => setShareDialogOpen(false)}
          onExportPDF={() => {
            const exportData = {
              buildName,
              components: buildSteps.map(step => ({
                category: step.label,
                component: selectedComponents[step.category]
              })),
              totalPrice: calculateTotalPrice(),
              compatibility
            };
            exportBuildToPDF(exportData);
          }}
          onExportExcel={() => {
            const exportData = {
              buildName,
              components: buildSteps.map(step => ({
                category: step.label,
                component: selectedComponents[step.category]
              })),
              totalPrice: calculateTotalPrice(),
              compatibility
            };
            exportBuildToExcel(exportData);
          }}
        />
      )}
    </div>
  );
}
