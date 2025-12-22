'use client';

import { useState, useEffect } from 'react';
import { Search, SlidersHorizontal, Grid3x3, List, ChevronLeft, ChevronRight } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Checkbox } from '@/components/ui/checkbox';
import { Badge } from '@/components/ui/badge';
import { ComponentCard } from '@/components/component-card';
import { ApiClient, Component, PaginatedResponse } from '@/lib/api';

const api = new ApiClient(process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8000/api/v1');

const categories = [
  { id: 'all', name: 'All Components', emoji: '🔧' },
  { id: 'cpu', name: 'Processors', emoji: '🖥️' },
  { id: 'motherboard', name: 'Motherboards', emoji: '🔲' },
  { id: 'video-card', name: 'Graphics Cards', emoji: '🎮' },
  { id: 'memory', name: 'Memory', emoji: '💾' },
  { id: 'internal-hard-drive', name: 'Storage', emoji: '💿' },
  { id: 'power-supply', name: 'Power Supply', emoji: '⚡' },
  { id: 'case', name: 'Cases', emoji: '🖼️' },
  { id: 'cpu-cooler', name: 'Cooling', emoji: '❄️' },
];

const sortOptions = [
  { value: 'relevance', label: 'Relevance' },
  { value: 'name_asc', label: 'Name (A-Z)' },
  { value: 'name_desc', label: 'Name (Z-A)' },
  { value: 'price_asc', label: 'Price (Low to High)' },
  { value: 'price_desc', label: 'Price (High to Low)' },
];

export default function ComponentsPage() {
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [sortBy, setSortBy] = useState('relevance');
  const [viewMode, setViewMode] = useState<'grid' | 'list'>('grid');
  const [showFilters, setShowFilters] = useState(false);
  const [components, setComponents] = useState<Component[]>([]);
  const [loading, setLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [brands, setBrands] = useState<string[]>([]);
  const [selectedBrands, setSelectedBrands] = useState<string[]>([]);
  const [priceRange, setPriceRange] = useState({ min: '', max: '' });

  // Fetch components
  useEffect(() => {
    const fetchComponents = async () => {
      setLoading(true);
      try {
        const params: {
          page?: number;
          per_page?: number;
          category?: string;
          search?: string;
          sort_by?: string;
          sort_order?: 'asc' | 'desc';
          brand_id?: number;
          min_price?: number;
          max_price?: number;
        } = {
          page: currentPage,
          per_page: 24,
        };

        if (selectedCategory !== 'all') {
          params.category = selectedCategory;
        }

        if (searchQuery) {
          params.search = searchQuery;
        }

        if (sortBy && sortBy !== 'relevance') {
          const [field, order] = sortBy.split('_');
          params.sort_by = field;
          params.sort_order = order as 'asc' | 'desc';
        }

        if (priceRange.min) {
          params.min_price = parseFloat(priceRange.min);
        }

        if (priceRange.max) {
          params.max_price = parseFloat(priceRange.max);
        }

        const response: PaginatedResponse<Component> = await api.getComponents(params);
        setComponents(response.data);
        setCurrentPage(response.meta.current_page);
        setTotalPages(response.meta.total_pages);

        // Extract unique brands from results
        const uniqueBrands = Array.from(
          new Set(
            response.data
              .filter(c => c.brand)
              .map(c => typeof c.brand === 'string' ? c.brand : c.brand_obj?.brand_name || '')
              .filter(b => b)
          )
        ).sort();
        setBrands(uniqueBrands);
      } catch (error) {
        console.error('Failed to fetch components:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchComponents();
  }, [selectedCategory, searchQuery, sortBy, currentPage, selectedBrands, priceRange]);

  const handleBrandToggle = (brand: string) => {
    setSelectedBrands(prev =>
      prev.includes(brand)
        ? prev.filter(b => b !== brand)
        : [...prev, brand]
    );
    setCurrentPage(1); // Reset to first page
  };

  const handlePriceFilter = () => {
    setCurrentPage(1);
  };

  const clearFilters = () => {
    setSelectedBrands([]);
    setPriceRange({ min: '', max: '' });
    setCurrentPage(1);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Breadcrumb */}
        <div className="text-sm text-muted-foreground mb-4">
          Home / Components
        </div>

        {/* Page Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold mb-4">Browse Components</h1>
          
          {/* Search Bar */}
          <div className="flex gap-4 items-center">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
              <Input
                type="text"
                placeholder="Search components..."
                value={searchQuery}
                onChange={(e) => {
                  setSearchQuery(e.target.value);
                  setCurrentPage(1);
                }}
                className="pl-10"
              />
            </div>
            <Button
              variant="outline"
              onClick={() => setShowFilters(!showFilters)}
              className="lg:hidden"
            >
              <SlidersHorizontal className="h-4 w-4 mr-2" />
              Filters
            </Button>
          </div>
        </div>

        {/* Category Tabs */}
        <div className="mb-6 overflow-x-auto">
          <div className="flex gap-2 pb-2">
            {categories.map((category) => (
              <Button
                key={category.id}
                variant={selectedCategory === category.id ? 'default' : 'outline'}
                onClick={() => {
                  setSelectedCategory(category.id);
                  setCurrentPage(1);
                }}
                className="whitespace-nowrap"
              >
                <span className="mr-2">{category.emoji}</span>
                {category.name}
              </Button>
            ))}
          </div>
        </div>

        <div className="flex gap-6">
          {/* Sidebar Filters */}
          <aside
            className={`${
              showFilters ? 'block' : 'hidden'
            } lg:block w-full lg:w-72 space-y-6`}
          >
            <div className="bg-white p-6 rounded-lg border shadow-sm">
              <div className="flex items-center justify-between mb-4">
                <h2 className="font-bold text-lg">Filters</h2>
                {(selectedBrands.length > 0 || priceRange.min || priceRange.max) && (
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={clearFilters}
                    className="text-xs"
                  >
                    Clear All
                  </Button>
                )}
              </div>

              {/* Price Range */}
              <div className="mb-6">
                <h3 className="font-semibold mb-3">Price Range (BDT)</h3>
                <div className="flex gap-2 mb-2">
                  <Input
                    type="number"
                    placeholder="Min"
                    value={priceRange.min}
                    onChange={(e) => setPriceRange({ ...priceRange, min: e.target.value })}
                    className="w-full"
                  />
                  <Input
                    type="number"
                    placeholder="Max"
                    value={priceRange.max}
                    onChange={(e) => setPriceRange({ ...priceRange, max: e.target.value })}
                    className="w-full"
                  />
                </div>
                <Button
                  size="sm"
                  onClick={handlePriceFilter}
                  className="w-full"
                  disabled={!priceRange.min && !priceRange.max}
                >
                  Apply
                </Button>
              </div>

              {/* Brand Filter */}
              {brands.length > 0 && (
                <div>
                  <h3 className="font-semibold mb-3">Brand</h3>
                  <div className="space-y-3 max-h-64 overflow-y-auto">
                    {brands.slice(0, 20).map((brand) => (
                      <div key={brand} className="flex items-center space-x-2">
                        <Checkbox
                          id={`brand-${brand}`}
                          checked={selectedBrands.includes(brand)}
                          onCheckedChange={() => handleBrandToggle(brand)}
                        />
                        <label
                          htmlFor={`brand-${brand}`}
                          className="text-sm cursor-pointer flex-1"
                        >
                          {brand}
                        </label>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </aside>

          {/* Main Content */}
          <main className="flex-1">
            {/* Sort & View Options */}
            <div className="bg-white p-4 rounded-lg border shadow-sm mb-6 flex flex-wrap items-center justify-between gap-4">
              <div className="flex items-center gap-3">
                <span className="text-sm text-muted-foreground">Sort by:</span>
                <Select value={sortBy} onValueChange={setSortBy}>
                  <SelectTrigger className="w-[180px]">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {sortOptions.map((option) => (
                      <SelectItem key={option.value} value={option.value}>
                        {option.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="flex items-center gap-2">
                <span className="text-sm text-muted-foreground">View:</span>
                <Button
                  variant={viewMode === 'grid' ? 'default' : 'outline'}
                  size="sm"
                  onClick={() => setViewMode('grid')}
                >
                  <Grid3x3 className="h-4 w-4" />
                </Button>
                <Button
                  variant={viewMode === 'list' ? 'default' : 'outline'}
                  size="sm"
                  onClick={() => setViewMode('list')}
                >
                  <List className="h-4 w-4" />
                </Button>
              </div>
            </div>

            {/* Active Filters */}
            {selectedBrands.length > 0 && (
              <div className="mb-4 flex flex-wrap gap-2">
                {selectedBrands.map((brand) => (
                  <Badge
                    key={brand}
                    variant="secondary"
                    className="cursor-pointer hover:bg-secondary/80"
                    onClick={() => handleBrandToggle(brand)}
                  >
                    {brand} ✕
                  </Badge>
                ))}
              </div>
            )}

            {/* Components Grid */}
            {loading ? (
              <div className="text-center py-12">
                <div className="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-current border-r-transparent align-[-0.125em] motion-reduce:animate-[spin_1.5s_linear_infinite]" />
                <p className="mt-4 text-muted-foreground">Loading components...</p>
              </div>
            ) : components.length === 0 ? (
              <div className="text-center py-12">
                <p className="text-lg text-muted-foreground">No components found</p>
                <p className="text-sm text-muted-foreground mt-2">
                  Try adjusting your filters or search query
                </p>
              </div>
            ) : (
              <>
                <div
                  className={
                    viewMode === 'grid'
                      ? 'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6'
                      : 'space-y-4'
                  }
                >
                  {components.map((component) => (
                    <ComponentCard key={component.id} component={component} />
                  ))}
                </div>

                {/* Pagination */}
                {totalPages > 1 && (
                  <div className="mt-8 flex items-center justify-center gap-2">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => setCurrentPage((prev) => Math.max(1, prev - 1))}
                      disabled={currentPage === 1}
                    >
                      <ChevronLeft className="h-4 w-4 mr-1" />
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
                      size="sm"
                      onClick={() => setCurrentPage((prev) => Math.min(totalPages, prev + 1))}
                      disabled={currentPage === totalPages}
                    >
                      Next
                      <ChevronRight className="h-4 w-4 ml-1" />
                    </Button>
                  </div>
                )}
              </>
            )}
          </main>
        </div>
      </div>
    </div>
  );
}
