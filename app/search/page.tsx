'use client';

import { useState, useEffect, Suspense } from 'react';
import { useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { Search } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent } from '@/components/ui/card';
import { ApiClient, Component, Build } from '@/lib/api';

const api = new ApiClient(process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8000/api/v1');

function SearchResultsContent() {
  const searchParams = useSearchParams();
  const query = searchParams.get('q') || '';
  const [searchQuery, setSearchQuery] = useState(query);
  const [activeTab, setActiveTab] = useState<'components' | 'builds'>('components');
  const [components, setComponents] = useState<Component[]>([]);
  const [builds, setBuilds] = useState<Build[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (query) {
      performSearch(query);
    }
  }, [query]);

  const performSearch = async (searchTerm: string) => {
    if (!searchTerm.trim()) return;

    setLoading(true);
    try {
      // Search components
      const componentsResponse = await api.getComponents({
        search: searchTerm,
        per_page: 20,
      });
      setComponents(componentsResponse.data);

      // Search builds
      const buildsResponse = await api.getBuilds({
        is_public: true,
        per_page: 20,
      });
      setBuilds(buildsResponse.data);
    } catch (error) {
      console.error('Search failed:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      window.history.pushState({}, '', `/search?q=${encodeURIComponent(searchQuery)}`);
      performSearch(searchQuery);
    }
  };

  const formatPrice = (price: number | string | null | undefined) => {
    if (!price) return 'N/A';
    const numPrice = typeof price === 'string' ? parseFloat(price) : price;
    return `৳${numPrice.toLocaleString('en-BD')}`;
  };

  const totalResults = activeTab === 'components' ? components.length : builds.length;

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Breadcrumb */}
        <div className="flex items-center gap-2 text-sm text-muted-foreground mb-6">
          <Link href="/" className="hover:text-primary">Home</Link>
          <span>/</span>
          <span className="text-foreground">Search Results</span>
        </div>

        {/* Search Bar */}
        <div className="mb-8">
          <form onSubmit={handleSearch} className="flex gap-3">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
              <Input
                type="text"
                placeholder="Search components, builds..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-10"
              />
            </div>
            <Button type="submit">Search</Button>
          </form>
        </div>

        {query && (
          <div className="mb-6">
            <h1 className="text-2xl font-bold mb-2">
              Search Results for &quot;{query}&quot;
            </h1>
            <p className="text-muted-foreground">
              Found {totalResults} {activeTab}
            </p>
          </div>
        )}

        {/* Tabs */}
        <div className="flex gap-4 border-b mb-6">
          <button
            onClick={() => setActiveTab('components')}
            className={`pb-3 px-2 border-b-2 transition-colors ${
              activeTab === 'components'
                ? 'border-primary text-primary font-medium'
                : 'border-transparent text-muted-foreground hover:text-foreground'
            }`}
          >
            Components ({components.length})
          </button>
          <button
            onClick={() => setActiveTab('builds')}
            className={`pb-3 px-2 border-b-2 transition-colors ${
              activeTab === 'builds'
                ? 'border-primary text-primary font-medium'
                : 'border-transparent text-muted-foreground hover:text-foreground'
            }`}
          >
            Builds ({builds.length})
          </button>
        </div>

        {loading ? (
          <div className="flex items-center justify-center py-12">
            <div className="text-center">
              <div className="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-current border-r-transparent" />
              <p className="mt-4 text-muted-foreground">Searching...</p>
            </div>
          </div>
        ) : (
          <>
            {/* Components Results */}
            {activeTab === 'components' && (
              <div>
                {components.length > 0 ? (
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {components.map((component) => (
                      <Link key={component.id} href={`/components/${component.id}`}>
                        <Card className="hover:shadow-lg transition-shadow h-full">
                          <CardContent className="p-6">
                            <div className="aspect-square bg-gray-100 rounded-lg mb-4 flex items-center justify-center">
                              <span className="text-4xl">
                                {component.category === 'cpu' && '🖥️'}
                                {component.category === 'motherboard' && '🔲'}
                                {component.category === 'video-card' && '🎮'}
                                {component.category === 'memory' && '💾'}
                                {component.category === 'internal-hard-drive' && '💿'}
                                {component.category === 'power-supply' && '⚡'}
                                {component.category === 'case' && '🖼️'}
                                {component.category === 'cpu-cooler' && '❄️'}
                              </span>
                            </div>
                            
                            <Badge variant="secondary" className="mb-2 capitalize">
                              {component.category}
                            </Badge>
                            
                            <h3 className="font-semibold mb-2 line-clamp-2">
                              {component.name}
                            </h3>
                            
                            {component.brand && (
                              <p className="text-sm text-muted-foreground mb-3">
                                {typeof component.brand === 'string' ? component.brand : component.brand_obj?.brand_name}
                              </p>
                            )}
                            
                            <div className="flex items-center justify-between">
                              <span className="text-lg font-bold text-primary">
                                {formatPrice(component.lowest_price_bdt)}
                              </span>
                              {component.featured && (
                                <Badge className="bg-yellow-500">Featured</Badge>
                              )}
                            </div>
                          </CardContent>
                        </Card>
                      </Link>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-12">
                    <p className="text-muted-foreground">No components found matching &quot;{query}&quot;</p>
                  </div>
                )}
              </div>
            )}

            {/* Builds Results */}
            {activeTab === 'builds' && (
              <div>
                {builds.length > 0 ? (
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {builds.map((build) => (
                      <Link key={build.id} href={`/builds/${build.id}`}>
                        <Card className="hover:shadow-lg transition-shadow h-full">
                          <CardContent className="p-6">
                            <div className="aspect-video bg-gray-100 rounded-lg mb-4 flex items-center justify-center">
                              <span className="text-gray-400">Build Image</span>
                            </div>
                            
                            <h3 className="font-semibold mb-2 line-clamp-1">
                              {build.name}
                            </h3>
                            
                            {build.description && (
                              <p className="text-sm text-muted-foreground mb-3 line-clamp-2">
                                {build.description}
                              </p>
                            )}
                            
                            <div className="flex items-center justify-between mb-3">
                              <span className="text-lg font-bold text-primary">
                                {formatPrice(build.total_price)}
                              </span>
                            </div>
                            
                            <div className="flex gap-4 text-sm text-muted-foreground">
                              <span>{build.is_complete ? 'Complete' : 'Incomplete'}</span>
                            </div>
                          </CardContent>
                        </Card>
                      </Link>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-12">
                    <p className="text-muted-foreground">No builds found matching &quot;{query}&quot;</p>
                  </div>
                )}
              </div>
            )}
          </>
        )}

        {/* No Query State */}
        {!query && !loading && (
          <div className="text-center py-12">
            <Search className="h-16 w-16 text-muted-foreground mx-auto mb-4" />
            <h2 className="text-xl font-semibold mb-2">Start Searching</h2>
            <p className="text-muted-foreground">
              Enter a search term to find components and builds
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

export default function SearchResultsPage() {
  return (
    <Suspense fallback={<div className="min-h-screen bg-gray-50 flex items-center justify-center"><p>Loading...</p></div>}>
      <SearchResultsContent />
    </Suspense>
  );
}
