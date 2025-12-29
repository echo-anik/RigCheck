<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Build;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class SharedBuildController extends Controller
{
    /**
     * Store a build for sharing
     */
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'components' => 'required|array',
            'total_price' => 'nullable|numeric',
            'compatibility' => 'nullable|array',
        ]);

        // Generate a unique share token
        $shareToken = Str::random(8);
        
        // Check if token already exists (very unlikely, but let's be safe)
        while (Build::where('share_token', $shareToken)->exists()) {
            $shareToken = Str::random(8);
        }

        $frontendUrl = env('FRONTEND_URL', 'http://localhost:3000');
        $shareUrl = $frontendUrl . '/builds/' . $shareToken;

        $build = Build::create([
            'share_token' => $shareToken,
            'share_url' => $shareUrl,
            'user_id' => auth()->id() ?? null,
            'build_name' => $request->name,
            'total_cost_bdt' => $request->total_price,
            'visibility' => 'public',
            'is_complete' => true,
        ]);

        // Store components to build_components table (convert product_id to actual id)
        $components = $request->components ?? [];
        foreach ($components as $component) {
            if (isset($component['id']) && isset($component['category'])) {
                // Find component by product_id
                $comp = \App\Models\Component::where('product_id', $component['id'])->first();
                if ($comp) {
                    $build->components()->attach($comp->id, [
                        'category' => $component['category'],
                        'quantity' => $component['quantity'] ?? 1,
                        'price_at_selection_bdt' => $component['price'] ?? null,
                    ]);
                }
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Build saved for sharing',
            'data' => [
                'build_id' => $build->id,
                'share_id' => $shareToken,
                'build_url' => $shareUrl,
            ]
        ], 201);
    }

    /**
     * Get a shared build by share token
     */
    public function show($shareToken)
    {
        $build = Build::where('share_token', $shareToken)
            ->where('visibility', 'public')
            ->with(['components.brand', 'components.specs', 'user'])
            ->first();

        if (!$build) {
            return response()->json([
                'success' => false,
                'message' => 'Build not found'
            ], 404);
        }

        // Increment view count
        $build->increment('view_count');

        // Format components data properly - components is a belongsToMany relationship
        $components = [];
        if ($build->components && $build->components->count() > 0) {
            foreach ($build->components as $component) {
                $components[] = [
                    'category' => $component->pivot->category ?? $component->category,
                    'product_id' => $component->product_id,
                    'name' => $component->name,
                    'brand' => $component->brand ? $component->brand->brand_name : null,
                    'price' => $component->pivot->price_at_selection_bdt ?? $component->lowest_price_bdt,
                    'price_at_selection_bdt' => $component->pivot->price_at_selection_bdt,
                    'lowest_price_bdt' => $component->lowest_price_bdt,
                    'primary_image_url' => $component->primary_image_url,
                    'image_urls' => $component->image_urls ?? [],
                    'quantity' => $component->pivot->quantity ?? 1,
                    'specs' => $component->specs_object ?? [],
                ];
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $build->id,
                'share_id' => $build->share_token,
                'share_token' => $build->share_token,
                'share_url' => $build->share_url,
                'name' => $build->build_name,
                'description' => $build->description,
                'use_case' => $build->use_case,
                'components' => $components,
                'total_price' => $build->total_cost_bdt,
                'total_cost_bdt' => $build->total_cost_bdt,
                'compatibility_status' => $build->compatibility_status,
                'compatibility' => $build->compatibility_issues,
                'view_count' => $build->view_count,
                'like_count' => $build->like_count,
                'visibility' => $build->visibility,
                'created_at' => $build->created_at,
                'updated_at' => $build->updated_at,
                'user' => $build->user ? [
                    'id' => $build->user->id,
                    'name' => $build->user->name,
                ] : null,
            ]
        ]);
    }

    /**
     * Get all public/featured builds
     */
    public function index(Request $request)
    {
        $query = Build::where('visibility', 'public')
            ->with(['components.brand', 'components.specs', 'user'])
            ->orderBy('created_at', 'desc');

        // Search by name
        if ($request->filled('search')) {
            $query->where('build_name', 'like', '%' . $request->search . '%');
        }

        $perPage = min($request->input('per_page', 20), 100);
        $builds = $query->paginate($perPage);

        // Transform the data
        $transformedData = [];
        foreach ($builds->items() as $build) {
            $transformedData[] = [
                'id' => $build->id,
                'share_id' => $build->share_token,
                'share_token' => $build->share_token,
                'name' => $build->build_name,
                'description' => $build->description,
                'use_case' => $build->use_case,
                'total_price' => $build->total_cost_bdt,
                'total_cost_bdt' => $build->total_cost_bdt,
                'view_count' => $build->view_count,
                'like_count' => $build->like_count,
                'compatibility_status' => $build->compatibility_status,
                'visibility' => $build->visibility,
                'is_complete' => $build->is_complete,
                'created_at' => $build->created_at,
                'components' => $build->components ? $build->components->map(function($component) {
                    return [
                        'id' => $component->id,
                        'product_id' => $component->product_id,
                        'category' => $component->pivot->category ?? $component->category,
                        'name' => $component->name,
                        'brand' => $component->brand ? $component->brand->brand_name : null,
                        'price_at_selection_bdt' => $component->pivot->price_at_selection_bdt,
                        'lowest_price_bdt' => $component->lowest_price_bdt,
                        'primary_image_url' => $component->primary_image_url,
                        'image_urls' => $component->image_urls ?? [],
                        'specs' => $component->specs_object ?? [],
                        'quantity' => $component->pivot->quantity ?? 1,
                    ];
                })->values()->all() : [],
                'user' => $build->user ? [
                    'id' => $build->user->id,
                    'name' => $build->user->name,
                ] : null,
            ];
        }

        return response()->json([
            'success' => true,
            'data' => $transformedData,
            'pagination' => [
                'current_page' => $builds->currentPage(),
                'last_page' => $builds->lastPage(),
                'per_page' => $builds->perPage(),
                'total' => $builds->total(),
            ]
        ]);
    }
}
