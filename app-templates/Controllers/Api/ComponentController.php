<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Component;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class ComponentController extends Controller
{
    /**
     * Display a listing of components.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $query = Component::with(['brand', 'specs']);

        // Filter by category
        if ($request->has('category')) {
            $query->category($request->category);
        }

        // Filter by brand
        if ($request->has('brand_id')) {
            $query->where('brand_id', $request->brand_id);
        }

        // Filter by availability
        if ($request->has('availability')) {
            $query->where('availability_status', $request->availability);
        }

        // Filter by price range
        if ($request->has('min_price')) {
            $query->where('lowest_price_usd', '>=', $request->min_price);
        }
        if ($request->has('max_price')) {
            $query->where('lowest_price_usd', '<=', $request->max_price);
        }

        // Search
        if ($request->has('search')) {
            $query->search($request->search);
        }

        // Featured only
        if ($request->boolean('featured')) {
            $query->featured();
        }

        // In stock only
        if ($request->boolean('in_stock')) {
            $query->inStock();
        }

        // Sorting
        $sortBy = $request->get('sort_by', 'popularity_score');
        $sortOrder = $request->get('sort_order', 'desc');
        $query->orderBy($sortBy, $sortOrder);

        // Pagination
        $perPage = $request->get('per_page', 20);
        $components = $query->paginate($perPage);

        // Transform data
        $components->getCollection()->transform(function ($component) {
            return $this->transformComponent($component);
        });

        return response()->json([
            'success' => true,
            'data' => [
                'components' => $components->items(),
                'meta' => [
                    'current_page' => $components->currentPage(),
                    'total_pages' => $components->lastPage(),
                    'total_count' => $components->total(),
                    'per_page' => $components->perPage(),
                ]
            ]
        ]);
    }

    /**
     * Display the specified component.
     *
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show($id): JsonResponse
    {
        $component = Component::with(['brand', 'specs', 'prices.retailer'])
                              ->findOrFail($id);

        // Increment view count
        $component->incrementViews();

        return response()->json([
            'success' => true,
            'data' => [
                'component' => $this->transformComponent($component, true)
            ]
        ]);
    }

    /**
     * Get components by category.
     *
     * @param  string  $category
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function byCategory($category, Request $request): JsonResponse
    {
        $request->merge(['category' => $category]);
        return $this->index($request);
    }

    /**
     * Get featured components.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function featured(Request $request): JsonResponse
    {
        $components = Component::with(['brand', 'specs'])
                               ->featured()
                               ->inStock()
                               ->orderByDesc('popularity_score')
                               ->limit($request->get('limit', 10))
                               ->get();

        $components->transform(function ($component) {
            return $this->transformComponent($component);
        });

        return response()->json([
            'success' => true,
            'data' => [
                'components' => $components
            ]
        ]);
    }

    /**
     * Search components.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function search(Request $request): JsonResponse
    {
        $request->validate([
            'q' => 'required|string|min:2'
        ]);

        $request->merge(['search' => $request->q]);
        return $this->index($request);
    }

    /**
     * Transform component data for API response.
     *
     * @param  \App\Models\Component  $component
     * @param  bool  $detailed
     * @return array
     */
    private function transformComponent($component, $detailed = false): array
    {
        $data = [
            'id' => $component->id,
            'product_id' => $component->product_id,
            'category' => $component->category,
            'name' => $component->name,
            'brand' => $component->brand ? $component->brand->brand_name : null,
            'brand_id' => $component->brand_id,
            'model' => $component->model,
            'series' => $component->series,
            'slug' => $component->slug,
            'image_url' => $component->primary_image_url,
            'price_usd' => $component->lowest_price_usd,
            'price_bdt' => $component->lowest_price_bdt,
            'availability_status' => $component->availability_status,
            'featured' => $component->featured,
            'popularity_score' => $component->popularity_score,
            'view_count' => $component->view_count,
            'build_count' => $component->build_count,
        ];

        // Add specs
        $specs = [];
        foreach ($component->specs as $spec) {
            $specs[$spec->spec_key] = [
                'value' => $spec->value,
                'unit' => $spec->spec_unit,
                'formatted' => $spec->formatted_value,
            ];
        }
        $data['specs'] = $specs;

        // Add detailed information if requested
        if ($detailed) {
            $data['description'] = $component->description ?? '';
            $data['image_urls'] = $component->image_urls ?? [];
            $data['tags'] = $component->tags ?? [];
            $data['release_date'] = $component->release_date?->format('Y-m-d');
            $data['data_version'] = $component->data_version;

            // Add pricing from different retailers
            if ($component->relationLoaded('prices')) {
                $data['prices'] = $component->prices->map(function ($price) {
                    return [
                        'retailer' => $price->retailer->retailer_name ?? 'Unknown',
                        'retailer_id' => $price->retailer_id,
                        'price_bdt' => $price->price_bdt,
                        'availability' => $price->availability_status,
                        'url' => $price->product_url,
                        'last_updated' => $price->scraped_at->diffForHumans(),
                    ];
                });
            }
        }

        return $data;
    }
}
