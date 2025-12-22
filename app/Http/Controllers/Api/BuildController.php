<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class BuildController extends Controller
{
    /**
     * Get all public builds (community feed)
     */
    public function publicBuilds(Request $request)
    {
        $query = DB::table('builds')
            ->leftJoin('users', 'builds.user_id', '=', 'users.id')
            ->where('builds.is_public', true)
            ->select(
                'builds.*',
                'users.name as user_name',
                'users.email as user_email'
            );

        // Search by name
        if ($request->filled('search')) {
            $query->where('builds.name', 'like', '%' . $request->search . '%');
        }

        // Filter by price range
        if ($request->has('min_cost')) {
            $query->where('builds.total_price', '>=', $request->min_cost);
        }
        if ($request->has('max_cost')) {
            $query->where('builds.total_price', '<=', $request->max_cost);
        }

        // Sorting
        $sortBy = $request->input('sort_by', 'builds.created_at');
        $sortOrder = $request->input('sort_order', 'desc');
        
        if (in_array($sortBy, ['created_at', 'total_price'])) {
            $query->orderBy('builds.' . $sortBy, $sortOrder);
        } else {
            $query->orderBy('builds.created_at', 'desc');
        }

        $perPage = $request->input('per_page', 20);
        $page = $request->input('page', 1);
        
        $totalCount = $query->count();
        $builds = $query->skip(($page - 1) * $perPage)->take($perPage)->get();

        // Add components to each build
        $builds = $builds->map(function($build) {
            $components = [];
            
            $componentIds = [
                'cpu' => $build->cpu_id,
                'motherboard' => $build->motherboard_id,
                'gpu' => $build->gpu_id,
                'ram' => $build->ram_id,
                'storage' => $build->storage_id,
                'psu' => $build->psu_id,
                'case' => $build->case_id,
                'cooler' => $build->cooler_id
            ];
            
            foreach ($componentIds as $category => $id) {
                if ($id) {
                    $component = DB::table('components')
                        ->where('id', $id)
                        ->first();
                    
                    if ($component) {
                        $specs = json_decode($component->specs, true);
                        $components[] = [
                            'id' => $component->id,
                            'category' => $component->category,
                            'brand' => $component->brand,
                            'name' => $component->model,
                            'specs' => $specs,
                            'image_url' => $specs['image_url'] ?? ''
                        ];
                    }
                }
            }
            
            $build->components = $components;
            $build->user = [
                'id' => $build->user_id,
                'name' => $build->user_name,
                'email' => $build->user_email
            ];
            
            unset($build->user_name);
            unset($build->user_email);
            
            return $build;
        });

        return response()->json([
            'success' => true,
            'data' => $builds,
            'meta' => [
                'current_page' => (int)$page,
                'total_pages' => ceil($totalCount / $perPage),
                'total_count' => $totalCount,
                'per_page' => (int)$perPage
            ]
        ]);
    }

    /**
     * Get authenticated user's builds
     */
    public function myBuilds(Request $request)
    {
        $query = DB::table('builds')
            ->where('builds.user_id', $request->user()->id)
            ->select('builds.*')
            ->orderBy('builds.created_at', 'desc');

        $perPage = $request->input('per_page', 20);
        $page = $request->input('page', 1);
        
        $totalCount = $query->count();
        $builds = $query->skip(($page - 1) * $perPage)->take($perPage)->get();

        // Add components to each build
        $builds = $builds->map(function($build) {
            $components = [];
            
            $componentIds = [
                'cpu' => $build->cpu_id,
                'motherboard' => $build->motherboard_id,
                'gpu' => $build->gpu_id,
                'ram' => $build->ram_id,
                'storage' => $build->storage_id,
                'psu' => $build->psu_id,
                'case' => $build->case_id,
                'cooler' => $build->cooler_id
            ];
            
            foreach ($componentIds as $category => $id) {
                if ($id) {
                    $component = DB::table('components')
                        ->where('id', $id)
                        ->first();
                    
                    if ($component) {
                        $specs = json_decode($component->specs, true);
                        $components[] = [
                            'id' => $component->id,
                            'category' => $component->category,
                            'brand' => $component->brand,
                            'name' => $component->model,
                            'specs' => $specs,
                            'image_url' => $specs['image_url'] ?? ''
                        ];
                    }
                }
            }
            
            $build->components = $components;
            
            return $build;
        });

        return response()->json([
            'success' => true,
            'data' => $builds,
            'meta' => [
                'current_page' => (int)$page,
                'total_pages' => ceil($totalCount / $perPage),
                'total_count' => $totalCount,
                'per_page' => (int)$perPage
            ]
        ]);
    }

    /**
     * Store a newly created build
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'total_price' => 'required|numeric|min:0',
            'is_public' => 'boolean',
            'cpu_id' => 'nullable|string|exists:components,id',
            'motherboard_id' => 'nullable|string|exists:components,id',
            'gpu_id' => 'nullable|string|exists:components,id',
            'ram_id' => 'nullable|string|exists:components,id',
            'storage_id' => 'nullable|string|exists:components,id',
            'psu_id' => 'nullable|string|exists:components,id',
            'case_id' => 'nullable|string|exists:components,id',
            'cooler_id' => 'nullable|string|exists:components,id',
        ]);

        $buildData = [
            'user_id' => $request->user()->id,
            'name' => $validated['name'],
            'description' => $validated['description'] ?? null,
            'total_price' => $validated['total_price'],
            'is_public' => $validated['is_public'] ?? false,
            'cpu_id' => $validated['cpu_id'] ?? null,
            'motherboard_id' => $validated['motherboard_id'] ?? null,
            'gpu_id' => $validated['gpu_id'] ?? null,
            'ram_id' => $validated['ram_id'] ?? null,
            'storage_id' => $validated['storage_id'] ?? null,
            'psu_id' => $validated['psu_id'] ?? null,
            'case_id' => $validated['case_id'] ?? null,
            'cooler_id' => $validated['cooler_id'] ?? null,
            'created_at' => now(),
            'updated_at' => now()
        ];

        $buildId = DB::table('builds')->insertGetId($buildData);
        $build = DB::table('builds')->where('id', $buildId)->first();

        return response()->json([
            'success' => true,
            'message' => 'Build created successfully',
            'data' => $build
        ], 201);
    }

    /**
     * Display the specified build
     */
    public function show($id)
    {
        $build = DB::table('builds')
            ->leftJoin('users', 'builds.user_id', '=', 'users.id')
            ->where('builds.id', $id)
            ->select(
                'builds.*',
                'users.name as user_name',
                'users.email as user_email'
            )
            ->first();

        if (!$build) {
            return response()->json([
                'success' => false,
                'message' => 'Build not found'
            ], 404);
        }

        // Get all components with prices
        $components = [];
        $componentIds = [
            'cpu' => $build->cpu_id,
            'motherboard' => $build->motherboard_id,
            'gpu' => $build->gpu_id,
            'ram' => $build->ram_id,
            'storage' => $build->storage_id,
            'psu' => $build->psu_id,
            'case' => $build->case_id,
            'cooler' => $build->cooler_id
        ];
        
        foreach ($componentIds as $category => $componentId) {
            if ($componentId) {
                $component = DB::table('components')
                    ->leftJoin('prices', 'components.id', '=', 'prices.component_id')
                    ->where('components.id', $componentId)
                    ->select(
                        'components.*',
                        DB::raw('MIN(prices.price_bdt) as lowest_price_bdt'),
                        DB::raw('MAX(prices.price_bdt) as highest_price_bdt')
                    )
                    ->groupBy('components.id', 'components.category', 'components.brand', 'components.model', 'components.specs', 'components.raw_name')
                    ->first();
                
                if ($component) {
                    $specs = json_decode($component->specs, true);
                    $components[] = [
                        'id' => $component->id,
                        'category' => $component->category,
                        'brand' => $component->brand,
                        'name' => $component->model,
                        'specs' => $specs,
                        'lowest_price_bdt' => $component->lowest_price_bdt,
                        'highest_price_bdt' => $component->highest_price_bdt,
                        'image_url' => $specs['image_url'] ?? ''
                    ];
                }
            }
        }

        $build->components = $components;
        $build->user = [
            'id' => $build->user_id,
            'name' => $build->user_name,
            'email' => $build->user_email
        ];
        
        unset($build->user_name);
        unset($build->user_email);

        return response()->json([
            'success' => true,
            'data' => $build
        ]);
    }

    /**
     * Update the specified build
     */
    public function update(Request $request, $id)
    {
        $build = DB::table('builds')->where('id', $id)->first();

        if (!$build) {
            return response()->json([
                'success' => false,
                'message' => 'Build not found'
            ], 404);
        }

        // Check ownership
        if ($build->user_id !== $request->user()->id) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name' => 'string|max:255',
            'description' => 'nullable|string',
            'total_price' => 'numeric|min:0',
            'is_public' => 'boolean',
            'cpu_id' => 'nullable|string|exists:components,id',
            'motherboard_id' => 'nullable|string|exists:components,id',
            'gpu_id' => 'nullable|string|exists:components,id',
            'ram_id' => 'nullable|string|exists:components,id',
            'storage_id' => 'nullable|string|exists:components,id',
            'psu_id' => 'nullable|string|exists:components,id',
            'case_id' => 'nullable|string|exists:components,id',
            'cooler_id' => 'nullable|string|exists:components,id',
        ]);

        $validated['updated_at'] = now();
        DB::table('builds')->where('id', $id)->update($validated);
        $build = DB::table('builds')->where('id', $id)->first();

        return response()->json([
            'success' => true,
            'message' => 'Build updated successfully',
            'data' => $build
        ]);
    }

    /**
     * Remove the specified build
     */
    public function destroy(Request $request, $id)
    {
        $build = DB::table('builds')->where('id', $id)->first();

        if (!$build) {
            return response()->json([
                'success' => false,
                'message' => 'Build not found'
            ], 404);
        }

        // Check ownership
        if ($build->user_id !== $request->user()->id) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        DB::table('builds')->where('id', $id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Build deleted successfully'
        ]);
    }
}
