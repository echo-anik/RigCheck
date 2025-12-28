<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Component;
use App\Models\Brand;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;

class AdminComponentController extends Controller
{
    /**
     * Display a listing of all components (admin view with more details)
     */
    public function index(Request $request)
    {
        $query = Component::with(['brand', 'specs'])
            ->select('components.*');

        // Filter by category
        if ($request->has('category') && $request->category !== 'all') {
            $query->where('category', $request->category);
        }

        // Search by name or brand
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', '%' . $search . '%')
                  ->orWhereHas('brand', function($brandQuery) use ($search) {
                      $brandQuery->where('brand_name', 'like', '%' . $search . '%');
                  });
            });
        }

        // Sorting
        $sortBy = $request->get('sort_by', 'created_at');
        $sortOrder = $request->get('sort_order', 'desc');
        $query->orderBy($sortBy, $sortOrder);

        // Pagination
        $perPage = min($request->get('per_page', 50), 100);
        $paginatedComponents = $query->paginate($perPage);

        // Transform the data
        $transformedData = [];
        foreach ($paginatedComponents->items() as $component) {
            $transformedData[] = [
                'id' => $component->id,
                'product_id' => $component->product_id,
                'category' => $component->category,
                'name' => $component->name,
                'brand' => $component->brand ? $component->brand->brand_name : null,
                'brand_id' => $component->brand_id,
                'lowest_price_bdt' => $component->lowest_price_bdt,
                'stock_count' => $component->stock_count,
                'featured' => $component->featured,
                'is_verified' => $component->is_verified,
                'availability_status' => $component->availability_status,
                'view_count' => $component->view_count,
                'build_count' => $component->build_count,
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
            ]
        ]);
    }

    /**
     * Store a newly created component (admin only)
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
            'is_verified' => 'nullable|boolean',
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
            'is_verified' => $validated['is_verified'] ?? false,
        ]);

        return response()->json([
            'success' => true,
            'data' => $component->load('brand'),
            'message' => 'Component created successfully'
        ], 201);
    }

    /**
     * Display the specified component (admin view)
     */
    public function show(string $id)
    {
        $component = Component::with(['brand', 'specs', 'prices'])
            ->find($id);

        if (!$component) {
            return response()->json([
                'success' => false,
                'message' => 'Component not found'
            ], 404);
        }

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
                'is_verified' => $component->is_verified,
                'view_count' => $component->view_count,
                'build_count' => $component->build_count,
                'specs' => $component->specs_object,
                'prices' => $component->prices,
                'created_at' => $component->created_at,
                'updated_at' => $component->updated_at,
            ]
        ]);
    }

    /**
     * Update the specified component (admin only)
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
            'is_verified' => 'nullable|boolean',
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

        // Update fields
        $component->fill(array_filter([
            'name' => $validated['name'] ?? null,
            'series' => $validated['series'] ?? null,
            'model' => $validated['model'] ?? null,
            'primary_image_url' => $validated['primary_image_url'] ?? null,
            'lowest_price_usd' => $validated['lowest_price_usd'] ?? null,
            'lowest_price_bdt' => $validated['lowest_price_bdt'] ?? null,
            'availability_status' => $validated['availability_status'] ?? null,
            'stock_count' => $validated['stock_count'] ?? null,
            'featured' => $validated['featured'] ?? null,
            'is_verified' => $validated['is_verified'] ?? null,
        ], function($value) {
            return $value !== null;
        }));

        if (isset($validated['image_urls'])) {
            $component->image_urls = $validated['image_urls'];
        }

        if (isset($validated['lowest_price_bdt']) || isset($validated['lowest_price_usd'])) {
            $component->price_last_updated = now();
        }

        $component->save();

        return response()->json([
            'success' => true,
            'data' => $component->load('brand'),
            'message' => 'Component updated successfully'
        ]);
    }

    /**
     * Remove the specified component (admin only)
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

        // Check if component is used in any builds
        $buildCount = DB::table('build_components')
            ->where('component_id', $id)
            ->count();

        if ($buildCount > 0) {
            return response()->json([
                'success' => false,
                'message' => "Cannot delete component. It is used in {$buildCount} build(s)."
            ], 400);
        }

        $component->delete();

        return response()->json([
            'success' => true,
            'message' => 'Component deleted successfully'
        ]);
    }

    /**
     * Get statistics for admin dashboard
     */
    public function stats()
    {
        $stats = [
            'total_components' => Component::count(),
            'by_category' => Component::select('category', DB::raw('count(*) as count'))
                ->groupBy('category')
                ->pluck('count', 'category'),
            'featured_count' => Component::where('featured', true)->count(),
            'verified_count' => Component::where('is_verified', true)->count(),
            'out_of_stock' => Component::where('availability_status', 'out_of_stock')->count(),
        ];

        return response()->json([
            'success' => true,
            'data' => $stats
        ]);
    }
}
