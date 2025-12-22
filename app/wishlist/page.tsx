'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { useWishlist } from '@/lib/wishlist-context';
import { useAuth } from '@/lib/auth-context';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Heart, Trash2, ShoppingCart } from 'lucide-react';
import { api, Build, Component as ApiComponent } from '@/lib/api';
import { toast } from 'sonner';

interface ComponentCardData {
  id: string;
  name: string;
  category: string;
  lowest_price_bdt: number;
  brand: string;
  image?: string | null;
}

export default function WishlistPage() {
  const { isAuthenticated } = useAuth();
  const { items, removeFromWishlist, hydrated } = useWishlist();
  const [components, setComponents] = useState<ComponentCardData[]>([]);
  const [builds, setBuilds] = useState<Build[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchWishlistItems = async () => {
      setLoading(true);
      try {
        const componentIds = items.filter((item) => item.type === 'component').map((item) => item.id);
        const buildIds = items.filter((item) => item.type === 'build').map((item) => item.id);

        if (componentIds.length === 0 && buildIds.length === 0) {
          setComponents([]);
          setBuilds([]);
          setLoading(false);
          return;
        }

        const [componentsData, buildsData] = await Promise.all([
          Promise.all(componentIds.map(async (id) => {
            try {
              const response = await api.getComponent(String(id));
              const comp = response.data || response;
              return {
                id: comp.id || comp.product_id,
                name: comp.name,
                category: comp.category,
                lowest_price_bdt: typeof comp.lowest_price_bdt === 'number' ? comp.lowest_price_bdt : (comp.lowest_price_bdt ? Number(comp.lowest_price_bdt) : 0),
                brand: comp.brand_obj?.brand_name || comp.brand || 'Unknown',
                image: comp.primary_image_url || comp.image_urls?.[0] || null,
              };
            } catch (error) {
              console.error(`Failed to fetch component ${id}:`, error);
              return null;
            }
          })),
          Promise.all(buildIds.map(async (id) => {
            try {
              const response = await api.getBuild(Number(id));
              return response.data || response;
            } catch (error) {
              console.error(`Failed to fetch build ${id}:`, error);
              return null;
            }
          })),
        ]);

        const filteredComponents = componentsData.filter((c) => c !== null) as ComponentCardData[];
        const filteredBuilds = buildsData.filter((b) => b !== null) as Build[];
        
        console.log('Loaded components:', filteredComponents);
        console.log('Loaded builds:', filteredBuilds);
        
        setComponents(filteredComponents);
        setBuilds(filteredBuilds);
      } catch (error) {
        console.error('Failed to fetch wishlist items:', error);
        toast.error('Failed to load wishlist items');
      } finally {
        setLoading(false);
      }
    };

    if (!hydrated) return;

    if (items.length > 0) {
      fetchWishlistItems();
    } else {
      setLoading(false);
    }
  }, [items, hydrated]);

  if (!isAuthenticated) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center px-4">
        <Card className="max-w-md">
          <CardHeader>
            <CardTitle>Sign In Required</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground mb-4">
              Please sign in to view your wishlist.
            </p>
            <Button asChild className="w-full">
              <Link href="/">Go to Home</Link>
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  const totalValue = components.reduce((sum, comp) => sum + comp.lowest_price_bdt, 0) +
                     builds.reduce((sum, build) => sum + (typeof build.total_price === 'string' ? parseFloat(build.total_price) : build.total_price), 0);

  return (
    <div className="bg-gray-50 min-h-screen py-8">
      <div className="max-w-7xl mx-auto px-4">
        <div className="mb-8">
          <h1 className="text-4xl font-bold mb-2 flex items-center gap-2">
            <Heart className="h-8 w-8 text-red-500 fill-red-500" />
            My Wishlist
          </h1>
          <p className="text-muted-foreground">
            {items.length} {items.length === 1 ? 'item' : 'items'} saved
            {totalValue > 0 && (
              <span className="ml-2">
                • Total Value: <span className="font-semibold">৳{totalValue.toLocaleString()}</span>
              </span>
            )}
          </p>
        </div>

        {loading ? (
          <div className="text-center py-12">
            <p className="text-muted-foreground">Loading wishlist...</p>
          </div>
        ) : items.length === 0 ? (
          <Card>
            <CardContent className="py-12 text-center">
              <Heart className="h-16 w-16 text-muted-foreground mx-auto mb-4" />
              <h3 className="text-xl font-semibold mb-2">Your wishlist is empty</h3>
              <p className="text-muted-foreground mb-6">
                Start adding components and builds you love!
              </p>
              <div className="flex gap-4 justify-center">
                <Button asChild>
                  <Link href="/components">Browse Components</Link>
                </Button>
                <Button variant="outline" asChild>
                  <Link href="/builds">View Builds</Link>
                </Button>
              </div>
            </CardContent>
          </Card>
        ) : components.length === 0 && builds.length === 0 ? (
          <Card>
            <CardContent className="py-12 text-center">
              <Heart className="h-16 w-16 text-muted-foreground mx-auto mb-4" />
              <h3 className="text-xl font-semibold mb-2">Unable to load wishlist items</h3>
              <p className="text-muted-foreground mb-2">
                {items.length} {items.length === 1 ? 'item' : 'items'} were saved but could not be loaded.
              </p>
              <p className="text-sm text-muted-foreground mb-6">
                This may happen if items were deleted. You can clear your wishlist and start fresh.
              </p>
              <div className="flex gap-4 justify-center">
                <Button variant="destructive" onClick={async () => {
                  if (window.confirm('Clear your wishlist?')) {
                    const { toast } = await import('sonner');
                    localStorage.removeItem('wishlist');
                    window.location.reload();
                    toast.success('Wishlist cleared');
                  }
                }}>
                  Clear Wishlist
                </Button>
                <Button variant="outline" asChild>
                  <Link href="/browse">Browse Components</Link>
                </Button>
              </div>
            </CardContent>
          </Card>
        ) : (
          <div className="space-y-8">
            {/* Components Section */}
            {components.length > 0 && (
              <div>
                <h2 className="text-2xl font-bold mb-4">Components ({components.length})</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {components.map((component) => (
                    <Card key={component.id}>
                      <CardContent className="p-4">
                        <div className="flex justify-between items-start mb-3">
                          <Badge>{component.category}</Badge>
                          <Button
                            size="icon"
                            variant="ghost"
                            onClick={async () => {
                              const { toast } = await import('sonner');
                              removeFromWishlist(component.id, 'component');
                              toast.success('Removed from wishlist');
                            }}
                          >
                            <Trash2 className="h-4 w-4 text-red-500" />
                          </Button>
                        </div>
                        <h3 className="font-semibold mb-2 line-clamp-2 flex items-center gap-2">
                          {component.image && (
                            <div className="relative h-10 w-10 flex-shrink-0">
                              <Image
                                src={component.image}
                                alt={component.name}
                                fill
                                className="rounded object-cover"
                                unoptimized
                              />
                            </div>
                          )}
                          <span className="flex-1">{component.name}</span>
                        </h3>
                        <p className="text-sm text-muted-foreground mb-2">
                          {component.brand}
                        </p>
                        <p className="text-xl font-bold text-primary mb-4">
                          ৳{component.lowest_price_bdt.toLocaleString()}
                        </p>
                        <div className="flex gap-2">
                          <Button size="sm" asChild className="flex-1">
                            <Link href={`/components/${component.id}`}>
                              View Details
                            </Link>
                          </Button>
                          <Button size="sm" variant="outline">
                            <ShoppingCart className="h-4 w-4" />
                          </Button>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              </div>
            )}

            {/* Builds Section */}
            {builds.length > 0 && (
              <div>
                <h2 className="text-2xl font-bold mb-4">Builds ({builds.length})</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {builds.map((build) => (
                    <Card key={build.id}>
                      <CardContent className="p-4">
                        <div className="flex justify-between items-start mb-3">
                          <div className="flex gap-2">
                            {build.visibility === 'private' && (
                              <Badge variant="secondary">Private</Badge>
                            )}
                          </div>
                          <Button
                            size="icon"
                            variant="ghost"
                            onClick={async () => {
                              const { toast } = await import('sonner');
                              removeFromWishlist(String(build.id), 'build');
                              toast.success('Removed from wishlist');
                            }}
                          >
                            <Trash2 className="h-4 w-4 text-red-500" />
                          </Button>
                        </div>
                        <h3 className="font-semibold mb-2 line-clamp-2">
                          {build.name}
                        </h3>
                        <p className="text-sm text-muted-foreground mb-2 line-clamp-2">
                          {build.description || 'No description'}
                        </p>
                        <p className="text-xl font-bold text-primary mb-4">
                          ৳{(typeof build.total_price === 'string' ? parseFloat(build.total_price) : build.total_price).toLocaleString()}
                        </p>
                        <Button size="sm" asChild className="w-full">
                          <Link href={`/builds/${build.id}`}>
                            View Build
                          </Link>
                        </Button>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
