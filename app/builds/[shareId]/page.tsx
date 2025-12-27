'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { ArrowLeft, Edit, Copy, Check } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { formatPriceBDT } from '@/lib/currency';
import { toast } from 'sonner';

interface BuildComponent {
  category: string;
  product_id: string;
  name: string;
  brand: string | null;
  price: number | string | null;
}

interface SharedBuild {
  id: number;
  share_id: string;
  name: string;
  components: BuildComponent[];
  total_price: number | null;
  compatibility: {
    is_compatible: boolean;
    warnings: string[];
    errors: string[];
  } | null;
  created_at: string;
}

export default function SharedBuildPage() {
  const params = useParams();
  const router = useRouter();
  const shareId = params.shareId as string;
  const [build, setBuild] = useState<SharedBuild | null>(null);
  const [loading, setLoading] = useState(true);
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    const fetchBuild = async () => {
      try {
        if (!shareId) {
          throw new Error('Invalid share ID');
        }

        const apiUrl = `${process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8000/api/v1'}/shared-builds/${shareId}`;
        console.log('Fetching shared build from:', apiUrl);
        
        const response = await fetch(apiUrl);
        
        if (!response.ok) {
          const errorText = await response.text();
          console.error(`API error ${response.status}:`, errorText);
          throw new Error(`Build not found (${response.status})`);
        }

        const result = await response.json();
        console.log('Shared build fetched:', result);
        
        const buildData = result.data || result;
        
        if (!buildData) {
          throw new Error('Invalid build data structure');
        }
        
        setBuild(buildData);
      } catch (error) {
        console.error('Failed to load build:', error);
        toast.error(error instanceof Error ? error.message : 'Build not found');
      } finally {
        setLoading(false);
      }
    };

    if (shareId) {
      fetchBuild();
    }
  }, [shareId]);

  const handleCopyLink = async () => {
    try {
      await navigator.clipboard.writeText(window.location.href);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
      toast.success('Link copied to clipboard!');
    } catch {
      toast.error('Failed to copy link');
    }
  };

  const handleCloneBuild = () => {
    if (!build) return;

    // Store build components in session storage for builder to load
    const componentsForBuilder: Record<string, BuildComponent> = {};
    build.components.forEach(comp => {
      componentsForBuilder[comp.category] = comp;
    });
    
    sessionStorage.setItem('pendingBuild', JSON.stringify(componentsForBuilder));
    sessionStorage.setItem('clonedBuildName', `${build.name} (Copy)`);
    
    router.push('/builder');
    toast.success('Build loaded! You can modify and save it.');
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-current border-r-transparent" />
          <p className="mt-4 text-muted-foreground">Loading build...</p>
        </div>
      </div>
    );
  }

  if (!build) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <h2 className="text-2xl font-bold mb-2">Build Not Found</h2>
          <p className="text-muted-foreground mb-6">The build you are looking for does not exist or has been removed.</p>
          <Button asChild>
            <Link href="/builder">Create Your Own Build</Link>
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Back Button */}
        <Button variant="ghost" asChild className="mb-6">
          <Link href="/builder">
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back to Builder
          </Link>
        </Button>

        {/* Build Header */}
        <Card className="mb-6">
          <CardHeader>
            <div className="flex items-center justify-between">
              <div>
                <CardTitle className="text-3xl mb-2">{build.name}</CardTitle>
                <p className="text-muted-foreground">
                  Shared on {new Date(build.created_at).toLocaleDateString()}
                </p>
              </div>
              <div className="text-right">
                <p className="text-sm text-muted-foreground mb-1">Total Cost</p>
                <p className="text-3xl font-bold text-primary">
                  {build.total_price ? formatPriceBDT(build.total_price) : 'N/A'}
                </p>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <div className="flex gap-3">
              <Button onClick={handleCloneBuild} className="flex-1">
                <Edit className="h-4 w-4 mr-2" />
                Clone & Modify
              </Button>
              <Button variant="outline" onClick={handleCopyLink}>
                {copied ? (
                  <>
                    <Check className="h-4 w-4 mr-2" />
                    Copied!
                  </>
                ) : (
                  <>
                    <Copy className="h-4 w-4 mr-2" />
                    Copy Link
                  </>
                )}
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* Compatibility Status */}
        {build.compatibility && (
          <Card className={`mb-6 ${
            build.compatibility.errors.length > 0
              ? 'border-red-500'
              : build.compatibility.warnings.length > 0
              ? 'border-yellow-500'
              : build.compatibility.is_compatible
              ? 'border-green-500'
              : ''
          }`}>
            <CardHeader>
              <CardTitle>
                {build.compatibility.is_compatible && build.compatibility.errors.length === 0
                  ? '✅ Compatible Build'
                  : '⚠️ Compatibility Issues'}
              </CardTitle>
            </CardHeader>
            <CardContent>
              {build.compatibility.errors.length > 0 && (
                <div className="space-y-2 mb-4">
                  <p className="font-semibold text-red-600">Errors:</p>
                  {build.compatibility.errors.map((error, index) => (
                    <p key={index} className="text-sm text-red-600">• {error}</p>
                  ))}
                </div>
              )}
              {build.compatibility.warnings.length > 0 && (
                <div className="space-y-2">
                  <p className="font-semibold text-yellow-600">Warnings:</p>
                  {build.compatibility.warnings.map((warning, index) => (
                    <p key={index} className="text-sm text-yellow-600">• {warning}</p>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>
        )}

        {/* Components List */}
        <Card>
          <CardHeader>
            <CardTitle>Build Components</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {build.components.map((component, index) => (
              <div key={index} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                <div className="flex-1">
                  <p className="text-sm text-muted-foreground mb-1">{component.category}</p>
                  <p className="font-semibold">{component.name}</p>
                  {component.brand && (
                    <p className="text-sm text-muted-foreground">{component.brand}</p>
                  )}
                </div>
                <div className="text-right">
                  <p className="font-bold text-primary">
                    {component.price ? formatPriceBDT(Number(component.price)) : 'N/A'}
                  </p>
                </div>
              </div>
            ))}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
