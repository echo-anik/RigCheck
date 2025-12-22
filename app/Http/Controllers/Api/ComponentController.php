<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ComponentController extends Controller
{
    /**
     * Display a listing of components with filtering and pagination.
     */
    public function index(Request $request)
    {
        // Map frontend category names to database category names
        $categoryMap = [
            'memory' => 'ram',
            'video-card' => 'gpu',
            'internal-hard-drive' => 'storage',
            'cpu-cooler' => 'cooler',
            'power-supply' => 'psu',
            // Direct mappings (no change)
            'cpu' => 'cpu',
            'motherboard' => 'motherboard',
            'case' => 'case',
        ];
        
        // Reverse map for response (database to frontend)
        $reverseCategoryMap = array_flip($categoryMap);
        
        $query = DB::table('components')
            ->leftJoin('component_prices', 'components.id', '=', 'component_prices.component_id')
            ->select(
                'components.id as product_id',
                'components.category',
                'components.brand',
                'components.name',
                'components.specs',
                DB::raw('MIN(component_prices.price_bdt) as lowest_price_bdt'),
                DB::raw('MAX(component_prices.price_bdt) as highest_price_bdt'),
                'components.created_at',
                'components.updated_at'
            )
            ->groupBy('components.id', 'components.category', 'components.brand', 'components.name', 
                     'components.specs', 'components.created_at', 'components.updated_at');

        // Filter by category (with mapping)
        if ($request->has('category') && $request->category !== 'all') {
            $dbCategory = $categoryMap[$request->category] ?? $request->category;
            $query->where('components.category', $dbCategory);
        }

        // Filter by brand
        if ($request->has('brand') || $request->has('brand_id')) {
            $brandSearch = $request->brand ?? $request->brand_id;
            $query->where('components.brand', 'like', '%' . $brandSearch . '%');
        }

        // Search by name
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('components.name', 'like', '%' . $search . '%')
                  ->orWhere('components.brand', 'like', '%' . $search . '%');
            });
        }

        // Price range filter
        if ($request->has('min_price')) {
            $query->havingRaw('MIN(component_prices.price_bdt) >= ?', [$request->min_price]);
        }
        if ($request->has('max_price')) {
            $query->havingRaw('MIN(component_prices.price_bdt) <= ?', [$request->max_price]);
        }

        // Sorting
        $sortBy = $request->get('sort_by', 'components.created_at');
        $sortOrder = $request->get('sort_order', 'desc');
        
        // Handle sorting by price
        if ($sortBy === 'price' || $sortBy === 'lowest_price_bdt') {
            $query->orderByRaw('MIN(component_prices.price_bdt) ' . $sortOrder);
        } else {
            $query->orderBy($sortBy, $sortOrder);
        }

        // Pagination
        $perPage = $request->get('per_page', 20);
        $page = $request->get('page', 1);
        
        // Get total count before pagination (using subquery to handle GROUP BY correctly)
        $countQuery = DB::table('components')
            ->leftJoin('component_prices', 'components.id', '=', 'component_prices.component_id')
            ->select('components.id')
            ->groupBy('components.id', 'components.category', 'components.brand', 'components.name', 
                     'components.specs', 'components.created_at', 'components.updated_at');
        
        // Apply same filters to count query
        if ($request->has('category') && $request->category !== 'all') {
            $dbCategory = $categoryMap[$request->category] ?? $request->category;
            $countQuery->where('components.category', $dbCategory);
        }
        if ($request->has('brand') || $request->has('brand_id')) {
            $brandSearch = $request->brand ?? $request->brand_id;
            $countQuery->where('components.brand', 'like', '%' . $brandSearch . '%');
        }
        if ($request->has('search')) {
            $search = $request->search;
            $countQuery->where(function($q) use ($search) {
                $q->where('components.name', 'like', '%' . $search . '%')
                  ->orWhere('components.brand', 'like', '%' . $search . '%');
            });
        }
        
        $totalCount = DB::table(DB::raw("({$countQuery->toSql()}) as subquery"))
            ->mergeBindings($countQuery)
            ->count();
        
        // Apply pagination
        $components = $query->skip(($page - 1) * $perPage)->take($perPage)->get();
        
        // Decode specs JSON, map categories back to frontend names, and add image_urls
        $components = $components->map(function($component) use ($reverseCategoryMap) {
            $specs = json_decode($component->specs, true);
            $component->specs = $specs;
            
            // Map database category back to frontend category
            $component->category = $reverseCategoryMap[$component->category] ?? $component->category;
            
            // Improve GPU names by incorporating chipset if not already in name
            if ($component->category === 'video-card' && !empty($specs['chipset'])) {
                $currentName = strtolower($component->name);
                $chipset = $specs['chipset'];
                $chipsetLower = strtolower($chipset);
                
                // Check if chipset is not already in the name
                if (strpos($currentName, $chipsetLower) === false) {
                    // Construct better name: Brand + Chipset + Model Variant
                    $component->name = trim($component->brand . ' ' . $chipset . ' ' . $component->name);
                }
            }
            
            // Extract image_url from specs for frontend compatibility
            $component->image_urls = !empty($specs['image_url']) ? [$specs['image_url']] : [];
            
            return $component;
        });

        return response()->json([
            'success' => true,
            'data' => $components,
            'meta' => [
                'current_page' => (int)$page,
                'total_pages' => ceil($totalCount / $perPage),
                'total_count' => $totalCount,
                'per_page' => (int)$perPage
            ]
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'category' => 'required|in:cpu,motherboard,gpu,ram,storage,psu,case,cooler',
            'brand' => 'required|string|max:100',
            'model' => 'required|string|max:200',
            'specs' => 'required|array',
            'price_bdt' => 'nullable|numeric'
        ]);

        // Generate ID
        $lastComponent = DB::table('components')
            ->where('category', $validated['category'])
            ->orderBy('id', 'desc')
            ->first();
        
        $index = 1;
        if ($lastComponent) {
            $index = (int)substr($lastComponent->id, 3) + 1;
        }
        
        $componentId = strtoupper(substr($validated['category'], 0, 3)) . str_pad($index, 6, '0', STR_PAD_LEFT);

        DB::table('components')->insert([
            'id' => $componentId,
            'category' => $validated['category'],
            'brand' => $validated['brand'],
            'name' => $validated['model'],
            'specs' => json_encode($validated['specs']),
            'created_at' => now(),
            'updated_at' => now()
        ]);
        
        // Add price if provided
        if (isset($validated['price_bdt']) && $validated['price_bdt'] > 0) {
            DB::table('component_prices')->insert([
                'component_id' => $componentId,
                'source' => 'manual',
                'price_bdt' => $validated['price_bdt'],
                'url' => '',
                'availability' => 'in_stock',
                'last_updated' => now()
            ]);
        }

        $component = DB::table('components')->where('id', $componentId)->first();

        return response()->json([
            'success' => true,
            'data' => $component,
            'message' => 'Component created successfully'
        ], 201);
    }

    /**
     * Display the specified component by product_id.
     */
    public function show(string $productId)
    {
        $component = DB::table('components')
            ->leftJoin('component_prices', 'components.id', '=', 'component_prices.component_id')
            ->where('components.id', $productId)
            ->select(
                'components.id as product_id',
                'components.category',
                'components.brand',
                'components.model as name',
                'components.specs',
                DB::raw('MIN(component_prices.price_bdt) as lowest_price_bdt'),
                DB::raw('MAX(component_prices.price_bdt) as highest_price_bdt')
            )
            ->groupBy('components.id', 'components.category', 'components.brand', 
                     'components.name', 'components.specs')
            ->first();

        if (!$component) {
            return response()->json([
                'success' => false,
                'message' => 'Component not found'
            ], 404);
        }

        $component->specs = json_decode($component->specs, true);
        $component->image_urls = !empty($component->specs['image_url']) ? [$component->specs['image_url']] : [];
        
        // Get all prices
        $prices = DB::table('component_prices')
            ->where('component_id', $productId)
            ->get();
        
        $component->prices = $prices;

        return response()->json([
            'success' => true,
            'data' => $component
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $component = DB::table('components')->where('id', $id)->first();
        
        if (!$component) {
            return response()->json([
                'success' => false,
                'message' => 'Component not found'
            ], 404);
        }

        $validated = $request->validate([
            'brand' => 'sometimes|string|max:100',
            'model' => 'sometimes|string|max:200',
            'specs' => 'sometimes|array'
        ]);

        $updateData = [];
        if (isset($validated['brand'])) $updateData['brand'] = $validated['brand'];
        if (isset($validated['model'])) {
            $updateData['model'] = $validated['model'];
            $updateData['raw_name'] = $validated['model'];
        }
        if (isset($validated['specs'])) $updateData['specs'] = json_encode($validated['specs']);
        $updateData['updated_at'] = now();

        DB::table('components')->where('id', $id)->update($updateData);

        $component = DB::table('components')->where('id', $id)->first();

        return response()->json([
            'success' => true,
            'data' => $component,
            'message' => 'Component updated successfully'
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $component = DB::table('components')->where('id', $id)->first();
        
        if (!$component) {
            return response()->json([
                'success' => false,
                'message' => 'Component not found'
            ], 404);
        }
        
        DB::table('components')->where('id', $id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Component deleted successfully'
        ]);
    }
}
