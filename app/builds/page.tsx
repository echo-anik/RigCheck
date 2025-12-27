'use client';

import { useState, useEffect } from 'react';
import { Search, SlidersHorizontal, TrendingUp, Users, Award } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { BuildCard } from '@/components/build-card';
import { ApiClient, Build, PaginatedResponse } from '@/lib/api';

const api = new ApiClient(process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8000/api/v1');

const buildTypes = [
  { id: 'all', name: 'All Builds', icon: Users },
  { id: 'gaming', name: 'Gaming', icon: Award },
  { id: 'workstation', name: 'Workstation', icon: TrendingUp },
  { id: 'budget', name: 'Budget', icon: SlidersHorizontal },
];

export default function BuildsPage() {
  const [selectedType, setSelectedType] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [builds, setBuilds] = useState<Build[]>([]);
  const [loading, setLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [featuredOnly, setFeaturedOnly] = useState(false);

  useEffect(() => {
    const fetchBuilds = async () => {
      setLoading(true);
      try {
        const params: {
          page?: number;
          per_page?: number;
          is_public?: boolean;
          featured?: boolean;
        } = {
          page: currentPage,
          per_page: 12,
          is_public: true,
        };

        if (featuredOnly) {
          params.featured = true;
        }

        const response: PaginatedResponse<Build> = await api.getBuilds(params);
        setBuilds(response.data);
        // Use pagination if available, otherwise fall back to meta
        const paginationData = response.pagination || response.meta;
        if (paginationData) {
          setCurrentPage(paginationData.current_page);
          // Type guard to check which pagination format we have
          const totalPages = 'last_page' in paginationData 
            ? paginationData.last_page 
            : ('total_pages' in paginationData ? paginationData.total_pages : 1);
          setTotalPages(totalPages);
        }
      } catch (error) {
        console.error('Failed to fetch builds:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchBuilds();
  }, [currentPage, featuredOnly]);

  // Filter builds by search query and type (client-side)
  const filteredBuilds = builds.filter((build) => {
    const matchesSearch = searchQuery
      ? build.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        build.description?.toLowerCase().includes(searchQuery.toLowerCase())
      : true;

    const matchesType = selectedType === 'all' || build.name.toLowerCase().includes(selectedType);

    return matchesSearch && matchesType;
  });

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h1 className="text-3xl font-bold mb-2">Build Gallery</h1>
              <p className="text-muted-foreground">
                Explore community PC builds and get inspired for your next project
              </p>
            </div>
            <Button
              variant={featuredOnly ? 'default' : 'outline'}
              onClick={() => {
                setFeaturedOnly(!featuredOnly);
                setCurrentPage(1);
              }}
            >
              <Award className="h-4 w-4 mr-2" />
              Featured
            </Button>
          </div>

          {/* Search Bar */}
          <div className="flex gap-4 items-center">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
              <Input
                type="text"
                placeholder="Search builds..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-10"
              />
            </div>
          </div>
        </div>

        {/* Build Type Filters */}
        <div className="mb-6 flex gap-2 overflow-x-auto pb-2">
          {buildTypes.map((type) => {
            const Icon = type.icon;
            return (
              <Button
                key={type.id}
                variant={selectedType === type.id ? 'default' : 'outline'}
                onClick={() => setSelectedType(type.id)}
                className="whitespace-nowrap"
              >
                <Icon className="h-4 w-4 mr-2" />
                {type.name}
              </Button>
            );
          })}
        </div>

        {/* Stats Bar */}
        <div className="bg-white rounded-lg border p-4 mb-6 grid grid-cols-2 md:grid-cols-4 gap-4">
          <div className="text-center">
            <div className="text-2xl font-bold text-primary">{builds.length}</div>
            <div className="text-sm text-muted-foreground">Total Builds</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-primary">
              {builds.filter((b) => b.visibility === 'public').length}
            </div>
            <div className="text-sm text-muted-foreground">Public</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-primary">
              {builds.length}
            </div>
            <div className="text-sm text-muted-foreground">Total Builds</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-primary">
              {builds.filter((b) => b.is_complete).length}
            </div>
            <div className="text-sm text-muted-foreground">Complete Builds</div>
          </div>
        </div>

        {/* Builds Grid */}
        {loading ? (
          <div className="text-center py-12">
            <div className="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-current border-r-transparent align-[-0.125em] motion-reduce:animate-[spin_1.5s_linear_infinite]" />
            <p className="mt-4 text-muted-foreground">Loading builds...</p>
          </div>
        ) : filteredBuilds.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-lg text-muted-foreground">No builds found</p>
            <p className="text-sm text-muted-foreground mt-2">
              Try adjusting your filters or search query
            </p>
          </div>
        ) : (
          <>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
              {filteredBuilds.map((build) => (
                <BuildCard key={build.id} build={build} />
              ))}
            </div>

            {/* Pagination */}
            {totalPages > 1 && (
              <div className="flex items-center justify-center gap-2">
                <Button
                  variant="outline"
                  onClick={() => setCurrentPage((prev) => Math.max(1, prev - 1))}
                  disabled={currentPage === 1}
                >
                  Previous
                </Button>

                <div className="flex items-center gap-1">
                  {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
                    let pageNum;
                    if (totalPages <= 5) {
                      pageNum = i + 1;
                    } else if (currentPage <= 3) {
                      pageNum = i + 1;
                    } else if (currentPage >= totalPages - 2) {
                      pageNum = totalPages - 4 + i;
                    } else {
                      pageNum = currentPage - 2 + i;
                    }

                    return (
                      <Button
                        key={pageNum}
                        variant={currentPage === pageNum ? 'default' : 'outline'}
                        size="sm"
                        onClick={() => setCurrentPage(pageNum)}
                      >
                        {pageNum}
                      </Button>
                    );
                  })}
                </div>

                <Button
                  variant="outline"
                  onClick={() => setCurrentPage((prev) => Math.min(totalPages, prev + 1))}
                  disabled={currentPage === totalPages}
                >
                  Next
                </Button>
              </div>
            )}
          </>
        )}

        {/* CTA Section */}
        <div className="mt-12 bg-primary text-primary-foreground rounded-lg p-8 text-center">
          <h2 className="text-2xl font-bold mb-2">Ready to Build Your Own PC?</h2>
          <p className="mb-6 opacity-90">
            Use our PC Builder tool to create your custom build with compatibility checking
          </p>
          <Button size="lg" variant="secondary" asChild>
            <a href="/builder">Start Building</a>
          </Button>
        </div>
      </div>
    </div>
  );
}
