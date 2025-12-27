'use client';

import { useState, useEffect, useMemo } from 'react';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { ApiClient, Component } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';
import { useRouter } from 'next/navigation';
import { BuildWizard, buildSteps } from '@/components/builder/BuildWizard';
import { BuildSummary } from '@/components/builder/BuildSummary';
import { toast } from 'sonner';

const api = new ApiClient(process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8000/api/v1');

export default function PCBuilderPage() {
  const { isAuthenticated } = useAuth();
  const router = useRouter();
  
  const [buildName, setBuildName] = useState('');
  const [buildId, setBuildId] = useState<number | null>(null);
  const [selectedComponents, setSelectedComponents] = useState<Record<string, Component | null>>(() => {
    const initial: Record<string, Component | null> = {};
    buildSteps.forEach(step => {
      initial[step.category] = null;
    });
    return initial;
  });
  
  const [availableComponents, setAvailableComponents] = useState<Record<string, Component[]>>({});
  const [saving, setSaving] = useState(false);
  const [compatibility, setCompatibility] = useState<{
    is_compatible: boolean;
    warnings: string[];
    errors: string[];
  } | null>(null);
  
  const [compatibilityCheck, setCompatibilityCheck] = useState<{
    category: string;
    status: 'idle' | 'checking' | 'compatible' | 'warning' | 'error';
    message?: string;
  } | null>(null);
  
  // Derive compatibility-aware component lists (e.g., motherboards filtered by CPU socket)
  const { filteredComponentsByCategory, compatibilityHints } = useMemo(() => {
    const filtered: Record<string, Component[]> = {};
    const hints: Record<string, string | undefined> = {};

    const cpu = selectedComponents['cpu'];
    const cpuSocket = cpu ? String(cpu.specs?.['socket'] || cpu.specs?.['socket_type'] || '').toLowerCase() : '';

    buildSteps.forEach((step) => {
      let comps = availableComponents[step.category] || [];

      if (step.category === 'motherboard' && cpu && cpuSocket) {
        const socketMatches = comps.filter((mb) => {
          const mbSocket = String(mb.specs?.['socket'] || mb.specs?.['socket_type'] || '').toLowerCase();
          return mbSocket && mbSocket === cpuSocket;
        });

        if (socketMatches.length > 0) {
          comps = socketMatches;
          hints[step.category] = `Showing motherboards with socket "${cpuSocket}" to match the selected CPU.`;
        } else {
          hints[step.category] = 'No exact socket matches found for this CPU. Showing all motherboards — please verify compatibility manually.';
        }
      }

      filtered[step.category] = comps;
    });

    return { filteredComponentsByCategory: filtered, compatibilityHints: hints };
  }, [availableComponents, selectedComponents]);

  // Load components for each category
  useEffect(() => {
    const loadComponents = async () => {
      const components: Record<string, Component[]> = {};
      
      for (const step of buildSteps) {
        try {
          const response = await api.getComponents({ category: step.category, per_page: 200 });
          components[step.category] = response.data;
        } catch (error) {
          console.error(`Failed to load ${step.category}:`, error);
          components[step.category] = [];
        }
      }
      
      setAvailableComponents(components);
    };
    
    loadComponents();

    // Load existing build for editing from session storage
    const editingBuildId = sessionStorage.getItem('editingBuildId');
    if (editingBuildId) {
      loadExistingBuild(parseInt(editingBuildId));
      sessionStorage.removeItem('editingBuildId');
    }

    // Load pending build from session storage (from "Add to Build" button)
    const pendingBuildData = sessionStorage.getItem('pendingBuild');
    if (pendingBuildData && !editingBuildId) {
      try {
        const pendingComponents = JSON.parse(pendingBuildData);
        setSelectedComponents(prev => ({
          ...prev,
          ...pendingComponents
        }));
        // Clear session storage after loading
        sessionStorage.removeItem('pendingBuild');
        toast.success('Components loaded from your previous selection!');
      } catch (error) {
        console.error('Failed to load pending build:', error);
      }
    }
  }, []);

  // Load existing build for editing
  const loadExistingBuild = async (id: number) => {
    try {
      const response = await api.getBuild(id);
      const build = response.data;
      
      setBuildId(id);
      setBuildName(build.name || '');
      
      // Map components from build to selected components
      const components: Record<string, Component | null> = {};
      buildSteps.forEach(step => {
        components[step.category] = null;
      });
      
      if (build.components && Array.isArray(build.components)) {
        build.components.forEach((comp: any) => {
          const category = comp.category;
          if (category) {
            // Create a Component object from the build component data
            components[category] = {
              id: comp.product_id || comp.id,
              product_id: comp.product_id,
              name: comp.name,
              brand: comp.brand,
              category: category,
              lowest_price_bdt: comp.price_at_selection_bdt || comp.lowest_price_bdt,
              primary_image_url: comp.primary_image_url,
              specs: comp.specs || {},
            } as Component;
          }
        });
      }
      
      setSelectedComponents(components);
      toast.success('Build loaded for editing!');
    } catch (error) {
      console.error('Failed to load build for editing:', error);
      toast.error('Failed to load build for editing');
      sessionStorage.removeItem('editingBuildId');
    }
  };

  // Real-time compatibility checking when components change
  useEffect(() => {
    const checkCompatibilityRealtime = async () => {
      const selectedCount = Object.values(selectedComponents).filter(c => c !== null).length;
      
      if (selectedCount < 2) {
        setCompatibility(null);
        return;
      }

      // Check compatibility with API
      try {
        const components: Record<string, string> = {};
        Object.entries(selectedComponents).forEach(([category, component]) => {
          if (component) {
            // Use category as-is since BuildWizard uses correct categories
            components[category] = component.id || component.product_id || '';
          }
        });

        const response = await api.checkCompatibility(components);
        
        const warnings: string[] = [];
        const errors: string[] = [];

        if (response.data.compatibility_checks) {
          const checks = response.data.compatibility_checks;

          if (checks.socket && !checks.socket.pass) {
            errors.push(checks.socket.message || 'CPU and Motherboard sockets are incompatible');
          }
          if (checks.ram_type && !checks.ram_type.pass) {
            errors.push(checks.ram_type.message || 'RAM type is incompatible with motherboard');
          }
          if (checks.form_factor && !checks.form_factor.pass) {
            errors.push(checks.form_factor.message || 'Motherboard form factor does not fit in case');
          }
          if (checks.gpu_clearance && !checks.gpu_clearance.pass) {
            warnings.push(checks.gpu_clearance.message || 'GPU may not fit in case');
          }
          if (checks.psu_wattage) {
            if (!checks.psu_wattage.pass) {
              errors.push(checks.psu_wattage.message || 'PSU wattage is insufficient');
            } else if (checks.psu_wattage.warning) {
              warnings.push(checks.psu_wattage.message || 'PSU wattage is close to limit');
            }
          }
        }

        setCompatibility({
          is_compatible: response.data.valid === true,
          warnings,
          errors,
        });
      } catch (error) {
        console.error('Real-time compatibility check failed:', error);
        
        // Show error to user
        const errorMessage = error instanceof Error ? error.message : 'Compatibility check failed';
        if (errorMessage.includes('500') || errorMessage.includes('Internal Server Error')) {
          toast.error('Compatibility check temporarily unavailable. Please try again.');
        } else if (errorMessage.includes('Failed to fetch') || errorMessage.includes('NetworkError')) {
          toast.error('Network error. Please check your connection.');
        }
        
        // Reset compatibility to allow user to continue
        setCompatibility(null);
      }
    };

    const debounceTimer = setTimeout(() => {
      checkCompatibilityRealtime();
    }, 500);

    return () => clearTimeout(debounceTimer);
  }, [selectedComponents]);

  const handleComponentSelect = (category: string, component: Component) => {
    setSelectedComponents(prev => ({
      ...prev,
      [category]: component
    }));
    
    // Show compatibility check animation
    setCompatibilityCheck({
      category,
      status: 'checking',
      message: 'Checking compatibility...'
    });
    
    setTimeout(() => {
      setCompatibilityCheck({
        category,
        status: 'compatible',
        message: 'Component is compatible!'
      });
      
      setTimeout(() => {
        setCompatibilityCheck(null);
      }, 2000);
    }, 800);
  };

  const handleComponentRemove = (category: string) => {
    setSelectedComponents(prev => ({
      ...prev,
      [category]: null
    }));
  };

  const handleEditComponent = (_category: string) => {
    // Scroll to top to show wizard
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleSaveBuild = async () => {
    const { toast } = await import('sonner');

    if (!isAuthenticated) {
      toast.error('Please sign in to save builds');
      router.push('/auth/signin');
      return;
    }

    if (!buildName.trim()) {
      toast.error('Please enter a build name');
      return;
    }

    const selectedCount = Object.values(selectedComponents).filter(c => c !== null).length;
    if (selectedCount === 0) {
      toast.error('Please select at least one component');
      return;
    }

    setSaving(true);
    try {
      // Build components array for API
      const components = Object.entries(selectedComponents)
        .filter(([_, component]) => component !== null)
        .map(([category, component]) => {
          const price = component!.lowest_price_bdt
            ? (typeof component!.lowest_price_bdt === 'string'
                ? parseFloat(component!.lowest_price_bdt)
                : component!.lowest_price_bdt)
            : 0;

          // Get the component ID - API expects the numeric id field
          const componentId = component!.product_id;
          
          console.log(`[Build Save] Adding component:`, {
            category,
            component_id: componentId,
            name: component!.name,
            price
          });

          return {
            component_id: componentId,
            category: category,
            quantity: 1,
            price_at_selection_bdt: price
          };
        });

      const buildData = {
        build_name: buildName.trim(),
        description: '',
        visibility: 'private' as 'private' | 'public',
        components: components
      };

      // Call API to save or update build
      let response;
      if (buildId) {
        response = await api.updateBuild(buildId, buildData);
        toast.success('Build updated successfully!', {
          description: `${buildName} has been updated.`,
          action: {
            label: 'View',
            onClick: () => router.push('/profile?tab=builds'),
          },
        });
      } else {
        response = await api.createBuild(buildData);
        if (response.data?.id) {
          setBuildId(response.data.id);
        }
        toast.success('Build saved successfully!', {
          description: `${buildName} has been saved to your profile.`,
          action: {
            label: 'View',
            onClick: () => router.push('/profile?tab=builds'),
          },
        });
      }

      // Clear build after successful save
      handleClearAll();
    } catch (error) {
      console.error('Failed to save build:', error);
      toast.error('Failed to save build', {
        description: error instanceof Error ? error.message : 'Please try again later.',
      });
    } finally {
      setSaving(false);
    }
  };

  const handleClearAll = async () => {
    const { toast } = await import('sonner');
    const initial: Record<string, Component | null> = {};
    buildSteps.forEach(step => {
      initial[step.category] = null;
    });
    setSelectedComponents(initial);
    setBuildName('');
    setCompatibility(null);
    toast.success('Build cleared');
  };



  const handleShareBuild = async (): Promise<{ buildId: string; buildUrl: string } | null> => {
    if (!buildName.trim()) {
      toast.error('Please enter a build name');
      return null;
    }

    const selectedCount = Object.values(selectedComponents).filter(c => c !== null).length;
    if (selectedCount === 0) {
      toast.error('Please select at least one component');
      return null;
    }

    try {
      // Calculate total cost
      const totalCost = Object.values(selectedComponents).reduce((total, component) => {
        if (component && component.lowest_price_bdt) {
          const price = typeof component.lowest_price_bdt === 'string'
            ? parseFloat(component.lowest_price_bdt)
            : component.lowest_price_bdt;
          return total + price;
        }
        return total;
      }, 0);

      // Prepare components data - API expects component IDs
      const components = Object.entries(selectedComponents)
        .filter(([_category, component]) => component !== null)
        .map(([category, component]) => ({
          id: component!.product_id,
          category,
          name: component!.name,
          brand: component!.brand,
          price: component!.lowest_price_bdt,
          quantity: 1
        }));

      console.log('[Share Build] Creating shared build:', {
        name: buildName.trim(),
        total_price: totalCost,
        component_count: components.length
      });

      // Call API to create shared build
      const response = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8000/api/v1'}/shared-builds`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          name: buildName.trim(),
          components,
          total_price: totalCost,
          compatibility
        }),
      });

      if (!response.ok) {
        throw new Error('Failed to create share link');
      }

      const data = await response.json();

      toast.success('Share link created!', {
        description: 'Your build is ready to share with others.',
      });

      return {
        buildId: data.data.share_id,
        buildUrl: data.data.build_url
      };
    } catch (error) {
      console.error('Failed to create share link:', error);
      toast.error('Failed to create share link', {
        description: error instanceof Error ? error.message : 'Please try again later.',
      });
      return null;
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Breadcrumb */}
        <div className="flex items-center gap-2 text-sm text-muted-foreground mb-6">
          <Link href="/" className="hover:text-primary">Home</Link>
          <span>/</span>
          <span className="text-foreground">PC Builder</span>
        </div>

        {/* Page Header */}
        <div className="mb-8">
          <div>
            <h1 className="text-3xl font-bold mb-2">Build Your Dream PC</h1>
            <p className="text-muted-foreground">
              Step-by-step wizard to help you select compatible components
            </p>
          </div>
        </div>

        {/* Main Content */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Left Column - Wizard */}
          <div className="lg:col-span-2">
            <BuildWizard
              availableComponents={filteredComponentsByCategory}
              selectedComponents={selectedComponents}
              onComponentSelect={handleComponentSelect}
              onComponentRemove={handleComponentRemove}
              compatibilityCheck={compatibilityCheck}
              compatibilityHints={compatibilityHints}
            />
          </div>

          {/* Right Column - Summary */}
          <div className="lg:col-span-1">
            <div className="sticky top-8">
              <BuildSummary
                selectedComponents={selectedComponents}
                buildName={buildName}
                onBuildNameChange={setBuildName}
                onSave={handleSaveBuild}
                onShare={handleShareBuild}
                onEdit={handleEditComponent}
                compatibility={compatibility}
                saving={saving}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
