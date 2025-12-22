'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';
import { ArrowLeft, ShoppingCart, Heart, Share2, CheckCircle2, AlertCircle, RefreshCw } from 'lucide-react';
import { toast } from 'sonner';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { api, Component } from '@/lib/api';
import { useWishlist } from '@/lib/wishlist-context';
import { formatPriceUSD, formatPriceBDT, USD_TO_BDT_RATE } from '@/lib/currency';

export default function ComponentDetailPage() {
  const params = useParams();
  const router = useRouter();
  const productId = params.productId as string;
  const { addToWishlist, removeFromWishlist, isInWishlist } = useWishlist();
  const [component, setComponent] = useState<Component | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showUSD, setShowUSD] = useState(false);

  const inWishlist = component?.id ? isInWishlist(component.id, 'component') : false;

  const handleAddToBuild = () => {
    if (!component) return;

    // Store component temporarily in session storage
    const existingBuild = sessionStorage.getItem('pendingBuild');
    const buildData = existingBuild ? JSON.parse(existingBuild) : {};
    
    // Add this component to the build
    buildData[component.category] = component;
    sessionStorage.setItem('pendingBuild', JSON.stringify(buildData));

    toast.success('Added to build!', {
      description: `${component.name} has been added. Continue building in the PC Builder.`,
      action: {
        label: 'Go to Builder',
        onClick: () => router.push('/builder'),
      },
    });
  };

  const handleShare = async () => {
    if (!component) return;

    const shareUrl = window.location.href;
    const shareText = `Check out this ${component.category}: ${component.name}`;

    if (navigator.share) {
      try {
        await navigator.share({
          title: component.name,
          text: shareText,
          url: shareUrl,
        });
      } catch (err) {
        console.log('Share cancelled');
      }
    } else {
      // Fallback: Copy to clipboard
      try {
        await navigator.clipboard.writeText(shareUrl);
        toast.success('Link copied to clipboard!');
      } catch (err) {
        toast.error('Failed to copy link');
      }
    }
  };

  const handleWishlistToggle = async () => {
    if (!component?.id) return;

    const { toast } = await import('sonner');

    if (inWishlist) {
      removeFromWishlist(component.id, 'component');
      toast.success('Removed from wishlist', {
        description: `${component.name} has been removed from your wishlist.`,
      });
    } else {
      addToWishlist(component.id, 'component');
      toast.success('Added to wishlist', {
        description: `${component.name} has been added to your wishlist.`,
      });
    }
  };

  useEffect(() => {
    const fetchComponent = async () => {
      try {
        setLoading(true);
        const response = await api.getComponent(productId);
        setComponent(response.data);
      } catch (err) {
        setError('Failed to load component details');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    if (productId) {
      fetchComponent();
    }
  }, [productId]);

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-current border-r-transparent" />
          <p className="mt-4 text-muted-foreground">Loading component...</p>
        </div>
      </div>
    );
  }

  if (error || !component) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <AlertCircle className="h-12 w-12 text-red-500 mx-auto mb-4" />
          <h2 className="text-2xl font-bold mb-2">Component Not Found</h2>
          <p className="text-muted-foreground mb-6">{error || 'The component you are looking for does not exist.'}</p>
          <Button asChild>
            <Link href="/components">Back to Components</Link>
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Breadcrumb */}
        <div className="flex items-center gap-2 text-sm text-muted-foreground mb-6">
          <Link href="/" className="hover:text-primary">Home</Link>
          <span>/</span>
          <Link href="/components" className="hover:text-primary">Components</Link>
          <span>/</span>
          <Link href={`/components?category=${component.category}`} className="hover:text-primary capitalize">
            {component.category}
          </Link>
          <span>/</span>
          <span className="text-foreground">{component.name}</span>
        </div>

        {/* Back Button */}
        <Button variant="ghost" asChild className="mb-6">
          <Link href="/components">
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back to Components
          </Link>
        </Button>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Left Column - Image & Actions */}
          <div className="lg:col-span-1 space-y-4">
            <Card>
              <CardContent className="p-6">
                {/* Component Image */}
                <div className="aspect-square bg-gray-100 rounded-lg flex items-center justify-center mb-6 overflow-hidden relative">
                  {component.primary_image_url || component.image_urls?.[0] ? (
                    <Image
                      src={(component.primary_image_url || component.image_urls?.[0]) as string}
                      alt={component.name}
                      fill
                      className="object-cover"
                      unoptimized
                    />
                  ) : (
                    <div className="text-center text-gray-400">
                      <div className="text-6xl mb-2">
                        {component.category === 'cpu' && '🖥️'}
                        {component.category === 'motherboard' && '🔲'}
                        {component.category === 'gpu' && '🎮'}
                        {component.category === 'ram' && '💾'}
                        {component.category === 'storage' && '💿'}
                        {component.category === 'psu' && '⚡'}
                        {component.category === 'case' && '🖼️'}
                        {component.category === 'cooler' && '❄️'}
                      </div>
                      <p className="text-sm">No Image Available</p>
                    </div>
                  )}
                </div>

                {/* Price */}
                <div className="mb-6">
                  <div className="flex items-center justify-between mb-2">
                    <div className="text-sm text-muted-foreground">Price</div>
                    <Button 
                      variant="ghost" 
                      size="sm"
                      onClick={() => setShowUSD(!showUSD)}
                      className="h-7 text-xs"
                    >
                      <RefreshCw className="h-3 w-3 mr-1" />
                      {showUSD ? 'Show BDT' : 'Show USD'}
                    </Button>
                  </div>
                  
                  {showUSD ? (
                    <>
                      <div className="text-3xl font-bold text-primary">
                        {formatPriceUSD(component.lowest_price_usd)}
                      </div>
                      <div className="text-sm text-muted-foreground mt-1">
                        ≈ {formatPriceBDT(component.lowest_price_usd ? component.lowest_price_usd * USD_TO_BDT_RATE : null)}
                      </div>
                    </>
                  ) : (
                    <>
                      <div className="text-3xl font-bold text-primary">
                        {formatPriceBDT(component.lowest_price_usd ? component.lowest_price_usd * USD_TO_BDT_RATE : null)}
                      </div>
                      <div className="text-sm text-muted-foreground mt-1">
                        {formatPriceUSD(component.lowest_price_usd)}
                      </div>
                    </>
                  )}
                  
                  <p className="text-xs text-muted-foreground mt-2">
                    *Approx. conversion at 1 USD = {USD_TO_BDT_RATE} BDT
                  </p>
                  
                  {component.availability_status && (
                    <div className="mt-2">
                      {component.availability_status === 'in_stock' ? (
                        <Badge className="bg-green-500">
                          <CheckCircle2 className="h-3 w-3 mr-1" />
                          In Stock
                        </Badge>
                      ) : (
                        <Badge variant="secondary">
                          <AlertCircle className="h-3 w-3 mr-1" />
                          Out of Stock
                        </Badge>
                      )}
                    </div>
                  )}
                </div>

                {/* Action Buttons */}
                <div className="space-y-3">
                  <Button className="w-full" size="lg" onClick={handleAddToBuild}>
                    <ShoppingCart className="h-4 w-4 mr-2" />
                    Add to Build
                  </Button>
                  <div className="grid grid-cols-2 gap-3">
                    <Button 
                      variant={inWishlist ? "default" : "outline"} 
                      size="lg"
                      onClick={handleWishlistToggle}
                    >
                      <Heart className={`h-4 w-4 mr-2 ${inWishlist ? 'fill-white' : ''}`} />
                      {inWishlist ? 'Saved' : 'Wishlist'}
                    </Button>
                    <Button variant="outline" size="lg" onClick={handleShare}>
                      <Share2 className="h-4 w-4 mr-2" />
                      Share
                    </Button>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Popularity Stats */}
            <Card>
              <CardHeader>
                <CardTitle className="text-base">Popularity</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex justify-between">
                  <span className="text-sm text-muted-foreground">Views</span>
                  <span className="font-semibold">{(component.view_count || 0).toLocaleString()}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-muted-foreground">In Builds</span>
                  <span className="font-semibold">{(component.build_count || 0).toLocaleString()}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-muted-foreground">Popularity Score</span>
                  <span className="font-semibold">{(component.popularity_score || 0).toFixed(1)}</span>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Right Column - Details */}
          <div className="lg:col-span-2 space-y-6">
            {/* Component Info */}
            <Card>
              <CardHeader>
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    {component.brand && (
                      <Badge variant="secondary" className="mb-3">
                        {typeof component.brand === 'string' ? component.brand : component.brand_obj?.brand_name}
                      </Badge>
                    )}
                    <h1 className="text-3xl font-bold mb-2">{component.name}</h1>
                    <div className="flex items-center gap-2 text-sm text-muted-foreground">
                      <span>SKU: {component.sku}</span>
                      <span>•</span>
                      <span className="capitalize">{component.category}</span>
                    </div>
                  </div>
                  {component.featured && (
                    <Badge className="bg-yellow-500">Featured</Badge>
                  )}
                </div>
              </CardHeader>
              <CardContent>
                {component.series && (
                  <div className="mb-4">
                    <span className="text-sm text-muted-foreground">Series: </span>
                    <span className="font-medium">{component.series}</span>
                  </div>
                )}
                {component.model && (
                  <div className="mb-4">
                    <span className="text-sm text-muted-foreground">Model: </span>
                    <span className="font-medium">{component.model}</span>
                  </div>
                )}
                {component.release_date && (
                  <div>
                    <span className="text-sm text-muted-foreground">Release Date: </span>
                    <span className="font-medium">
                      {new Date(component.release_date).toLocaleDateString('en-US', {
                        year: 'numeric',
                        month: 'long',
                        day: 'numeric',
                      })}
                    </span>
                  </div>
                )}
              </CardContent>
            </Card>

            {/* Specifications */}
            {component.specs && typeof component.specs === 'object' && Object.keys(component.specs).length > 0 && (
              <Card>
                <CardHeader>
                  <CardTitle>Specifications</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="grid gap-4">
                    {Object.entries(component.specs).map(([key, value], index) => (
                      <div key={index} className="grid grid-cols-3 gap-4 py-3 border-b last:border-0">
                        <div className="font-medium text-sm">
                          {key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}
                        </div>
                        <div className="col-span-2 text-sm text-muted-foreground">
                          {value !== null && value !== undefined ? String(value) : 'N/A'}
                        </div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            )}

            {/* Compatibility Notes */}
            <Card>
              <CardHeader>
                <CardTitle>Compatibility</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-muted-foreground">
                  This {component.category} can be checked for compatibility with other components using our PC Builder tool.
                </p>
                <Button className="mt-4" asChild>
                  <Link href="/builder">Check Compatibility</Link>
                </Button>
              </CardContent>
            </Card>
          </div>
        </div>

        {/* Related Components CTA */}
        <Card className="mt-8">
          <CardContent className="py-8 text-center">
            <h3 className="text-xl font-bold mb-2">Looking for Similar Components?</h3>
            <p className="text-muted-foreground mb-4">
              Browse more {component.category} components from {typeof component.brand === 'string' ? component.brand : component.brand_obj?.brand_name}
            </p>
            <Button variant="outline" asChild>
              <Link href={`/components?category=${component.category}&brand=${typeof component.brand === 'string' ? component.brand : component.brand_obj?.brand_name}`}>
                View Similar Components
              </Link>
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
