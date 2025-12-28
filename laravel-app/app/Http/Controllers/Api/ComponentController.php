<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Component;
use App\Models\Brand;
use App\Models\ComponentPrice;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class ComponentController extends Controller
{
    /**
     * Display a listing of components with filtering and pagination.
     */
    public function index(Request $request)
    {
        $query = Component::with(['brand', 'specs'])
            ->select('components.*');

        // Filter by category
        if ($request->has('category') && $request->category !== 'all') {
            $query->where('category', $request->category);
        }

        // Filter by brand (search by brand name or brand_id)
        if ($request->has('brand')) {
            $query->whereHas('brand', function($q) use ($request) {
                $q->where('brand_name', 'like', '%' . $request->brand . '%');
            });
        }

        if ($request->has('brand_id')) {
            $query->where('brand_id', $request->brand_id);
        }

        // Search by name
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', '%' . $search . '%')
                  ->orWhereHas('brand', function($brandQuery) use ($search) {
                      $brandQuery->where('brand_name', 'like', '%' . $search . '%');
                  });
            });
        }

        // Price range filter
        if ($request->has('min_price')) {
            $query->where('lowest_price_bdt', '>=', $request->min_price);
        }
        if ($request->has('max_price')) {
            $query->where('lowest_price_bdt', '<=', $request->max_price);
        }

        // Featured filter
        if ($request->has('featured')) {
            $query->where('featured', $request->featured);
        }

        // Availability filter
        if ($request->has('availability')) {
            $query->where('availability_status', $request->availability);
        }

        // Sorting
        $sortBy = $request->get('sort_by', 'created_at');
        $sortOrder = $request->get('sort_order', 'desc');

        // Map common sort fields
        $sortFieldMap = [
            'price' => 'lowest_price_bdt',
            'name' => 'name',
            'popularity' => 'popularity_score',
            'created_at' => 'created_at'
        ];

        $sortField = $sortFieldMap[$sortBy] ?? $sortBy;
        $query->orderBy($sortField, $sortOrder);

        // Pagination
        $perPage = $request->get('per_page', 20);
        $perPage = min($perPage, 100); // Max 100 items per page

        $paginatedComponents = $query->paginate($perPage);

        // Transform the data for response
        $transformedData = [];
        foreach ($paginatedComponents->items() as $component) {
            // Load specs if not loaded
            if (!$component->relationLoaded('specs')) {
                $component->load('specs');
            }
            
            $transformedData[] = [
                'id' => $component->id,
                'product_id' => $component->product_id,
                'sku' => $component->sku,
                'category' => $component->category,
                'name' => $component->name,
                'brand' => $component->brand ? $component->brand->brand_name : null,
                'brand_id' => $component->brand_id,
                'brand_slug' => $component->brand ? $component->brand->brand_slug : null,
                'series' => $component->series,
                'model' => $component->model,
                'slug' => $component->slug,
                'primary_image_url' => $component->primary_image_url,
                'image_urls' => $component->image_urls ?? [],
                'lowest_price_usd' => $component->lowest_price_usd,
                'lowest_price_bdt' => $component->lowest_price_bdt,
                'price_last_updated' => $component->price_last_updated,
                'availability_status' => $component->availability_status,
                'stock_count' => $component->stock_count,
                'featured' => $component->featured,
                'popularity_score' => $component->popularity_score,
                'view_count' => $component->view_count,
                'build_count' => $component->build_count,
                'is_verified' => $component->is_verified,
                'release_date' => $component->release_date,
                'specs' => $component->specs_object,
                'created_at' => $component->created_at,
                'updated_at' => $component->updated_at,
            ];
        }

        return response()->json([
            'success' => true,
            'data' => $transformedData,
            'pagination' => [
                'current_page' => $paginatedComponents->currentPage(),
                'last_page' => $paginatedComponents->lastPage(),
                'per_page' => $paginatedComponents->perPage(),
                'total' => $paginatedComponents->total(),
                'from' => $paginatedComponents->firstItem(),
                'to' => $paginatedComponents->lastItem(),
            ]
        ]);
    }

    /**
     * Store a newly created component.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'category' => 'required|in:cpu,motherboard,gpu,ram,storage,psu,case,cooler',
            'name' => 'required|string|max:500',
            'brand_name' => 'required|string|max:100',
            'series' => 'nullable|string|max:255',
            'model' => 'nullable|string|max:255',
            'primary_image_url' => 'nullable|url',
            'image_urls' => 'nullable|array',
            'lowest_price_usd' => 'nullable|numeric|min:0',
            'lowest_price_bdt' => 'nullable|numeric|min:0',
            'availability_status' => 'nullable|in:in_stock,out_of_stock,pre_order,discontinued',
            'stock_count' => 'nullable|integer|min:0',
            'featured' => 'nullable|boolean',
        ]);

        // Get or create brand
        $brand = Brand::firstOrCreate(
            ['brand_name' => $validated['brand_name']],
            [
                'brand_slug' => Str::slug($validated['brand_name']),
                'is_active' => true
            ]
        );

        // Generate product_id and slug
        $productId = Str::slug($validated['name']);
        $slug = $productId;

        // Ensure uniqueness
        $counter = 1;
        while (Component::where('product_id', $productId)->exists()) {
            $productId = $slug . '-' . $counter;
            $counter++;
        }

        $component = Component::create([
            'product_id' => $productId,
            'sku' => $productId,
            'category' => $validated['category'],
            'name' => $validated['name'],
            'brand_id' => $brand->id,
            'series' => $validated['series'] ?? null,
            'model' => $validated['model'] ?? null,
            'slug' => $productId,
            'primary_image_url' => $validated['primary_image_url'] ?? null,
            'image_urls' => json_encode($validated['image_urls'] ?? []),
            'lowest_price_usd' => $validated['lowest_price_usd'] ?? null,
            'lowest_price_bdt' => $validated['lowest_price_bdt'] ?? null,
            'price_last_updated' => now(),
            'availability_status' => $validated['availability_status'] ?? 'in_stock',
            'stock_count' => $validated['stock_count'] ?? 0,
            'featured' => $validated['featured'] ?? false,
        ]);

        return response()->json([
            'success' => true,
            'data' => $component->load('brand'),
            'message' => 'Component created successfully'
        ], 201);
    }

    /**
     * Display the specified component.
     */
    public function show(string $productId)
    {
        $component = Component::with(['brand', 'specs', 'prices'])
            ->where('product_id', $productId)
            ->orWhere('slug', $productId)
            ->first();

        if (!$component) {
            return response()->json([
                'success' => false,
                'message' => 'Component not found'
            ], 404);
        }

        // Increment view count
        $component->increment('view_count');

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $component->id,
                'product_id' => $component->product_id,
                'sku' => $component->sku,
                'category' => $component->category,
                'name' => $component->name,
                'brand' => $component->brand ? $component->brand->brand_name : null,
                'brand_id' => $component->brand_id,
                'brand_slug' => $component->brand ? $component->brand->brand_slug : null,
                'series' => $component->series,
                'model' => $component->model,
                'slug' => $component->slug,
                'primary_image_url' => $component->primary_image_url,
                'image_urls' => $component->image_urls ?? [],
                'lowest_price_usd' => $component->lowest_price_usd,
                'lowest_price_bdt' => $component->lowest_price_bdt,
                'price_last_updated' => $component->price_last_updated,
                'availability_status' => $component->availability_status,
                'stock_count' => $component->stock_count,
                'featured' => $component->featured,
                'popularity_score' => $component->popularity_score,
                'view_count' => $component->view_count,
                'build_count' => $component->build_count,
                'is_verified' => $component->is_verified,
                'release_date' => $component->release_date,
                'specs' => $component->specs_object,
                'prices' => $component->prices,
                'created_at' => $component->created_at,
                'updated_at' => $component->updated_at,
            ]
        ]);
    }

    /**
     * Update the specified component.
     */
    public function update(Request $request, string $id)
    {
        $component = Component::find($id);

        if (!$component) {
            return response()->json([
                'success' => false,
                'message' => 'Component not found'
            ], 404);
        }

        $validated = $request->validate([
            'name' => 'sometimes|string|max:500',
            'brand_name' => 'sometimes|string|max:100',
            'series' => 'nullable|string|max:255',
            'model' => 'nullable|string|max:255',
            'primary_image_url' => 'nullable|url',
            'image_urls' => 'nullable|array',
            'lowest_price_usd' => 'nullable|numeric|min:0',
            'lowest_price_bdt' => 'nullable|numeric|min:0',
            'availability_status' => 'nullable|in:in_stock,out_of_stock,pre_order,discontinued',
            'stock_count' => 'nullable|integer|min:0',
            'featured' => 'nullable|boolean',
        ]);

        // Update brand if provided
        if (isset($validated['brand_name'])) {
            $brand = Brand::firstOrCreate(
                ['brand_name' => $validated['brand_name']],
                [
                    'brand_slug' => Str::slug($validated['brand_name']),
                    'is_active' => true
                ]
            );
            $component->brand_id = $brand->id;
        }

        // Update other fields
        if (isset($validated['name'])) {
            $component->name = $validated['name'];
        }
        if (isset($validated['series'])) {
            $component->series = $validated['series'];
        }
        if (isset($validated['model'])) {
            $component->model = $validated['model'];
        }
        if (isset($validated['primary_image_url'])) {
            $component->primary_image_url = $validated['primary_image_url'];
        }
        if (isset($validated['image_urls'])) {
            $component->image_urls = $validated['image_urls'];
        }
        if (isset($validated['lowest_price_usd'])) {
            $component->lowest_price_usd = $validated['lowest_price_usd'];
            $component->price_last_updated = now();
        }
        if (isset($validated['lowest_price_bdt'])) {
            $component->lowest_price_bdt = $validated['lowest_price_bdt'];
            $component->price_last_updated = now();
        }
        if (isset($validated['availability_status'])) {
            $component->availability_status = $validated['availability_status'];
        }
        if (isset($validated['stock_count'])) {
            $component->stock_count = $validated['stock_count'];
        }
        if (isset($validated['featured'])) {
            $component->featured = $validated['featured'];
        }

        $component->save();

        return response()->json([
            'success' => true,
            'data' => $component->load('brand'),
            'message' => 'Component updated successfully'
        ]);
    }

    /**
     * Remove the specified component.
     */
    public function destroy(string $id)
    {
        $component = Component::find($id);

        if (!$component) {
            return response()->json([
                'success' => false,
                'message' => 'Component not found'
            ], 404);
        }

        $component->delete();

        return response()->json([
            'success' => true,
            'message' => 'Component deleted successfully'
        ]);
    }

    /**
     * Get component counts by category.
     */
    public function getCategoryCounts()
    {
        $counts = Component::select('category', DB::raw('count(*) as count'))
            ->groupBy('category')
            ->get()
            ->pluck('count', 'category');

        return response()->json([
            'success' => true,
            'data' => [
                'cpu' => $counts['cpu'] ?? 0,
                'motherboard' => $counts['motherboard'] ?? 0,
                'gpu' => $counts['gpu'] ?? 0,
                'ram' => $counts['ram'] ?? 0,
                'storage' => $counts['storage'] ?? 0,
                'psu' => $counts['psu'] ?? 0,
                'case' => $counts['case'] ?? 0,
                'cooler' => $counts['cooler'] ?? 0,
                'total' => array_sum($counts->toArray())
            ]
        ]);
    }
}
