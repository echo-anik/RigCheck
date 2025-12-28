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
            ->with('components')
            ->first();

        if (!$build) {
            return response()->json([
                'success' => false,
                'message' => 'Build not found'
            ], 404);
        }

        // Format components data
        $components = [];
        if ($build->components && count($build->components) > 0) {
            foreach ($build->components as $buildComponent) {
                $components[] = [
                    'category' => $buildComponent->category,
                    'product_id' => $buildComponent->product_id,
                    'name' => $buildComponent->component->name ?? 'Unknown',
                    'brand' => $buildComponent->component->brand ?? null,
                    'price' => $buildComponent->component->lowest_price_bdt ?? null,
                ];
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $build->id,
                'share_id' => $build->share_token,
                'name' => $build->build_name,
                'components' => $components,
                'total_price' => $build->total_cost_bdt,
                'compatibility' => $build->compatibility_issues,
                'created_at' => $build->created_at,
            ]
        ]);
    }

    /**
     * Get all public/featured builds
     */
    public function index()
    {
        $builds = Build::where('visibility', 'public')
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $builds->map(function ($build) {
                return [
                    'id' => $build->id,
                    'share_id' => $build->share_token,
                    'name' => $build->build_name,
                    'total_price' => $build->total_cost_bdt,
                    'created_at' => $build->created_at,
                ];
            }),
            'pagination' => [
                'current_page' => $builds->currentPage(),
                'last_page' => $builds->lastPage(),
                'per_page' => $builds->perPage(),
                'total' => $builds->total(),
            ]
        ]);
    }
}
