<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Build;
use App\Models\Component;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class BuildController extends Controller
{
    /**
     * Get all public builds (community feed)
     */
    public function publicBuilds(Request $request)
    {
        $query = Build::with(['user', 'components.brand', 'components.specs'])
            ->where('visibility', 'public');

        // Search by name
        if ($request->filled('search')) {
            $query->where('build_name', 'like', '%' . $request->search . '%');
        }

        // Filter by use case
        if ($request->filled('use_case')) {
            $query->where('use_case', $request->use_case);
        }

        // Filter by price range
        if ($request->has('min_cost')) {
            $query->where('total_cost_bdt', '>=', $request->min_cost);
        }
        if ($request->has('max_cost')) {
            $query->where('total_cost_bdt', '<=', $request->max_cost);
        }

        // Sorting
        $sortBy = $request->input('sort_by', 'created_at');
        $sortOrder = $request->input('sort_order', 'desc');

        $allowedSortFields = ['created_at', 'total_cost_bdt', 'view_count', 'like_count', 'popularity_score'];
        if (in_array($sortBy, $allowedSortFields)) {
            $query->orderBy($sortBy, $sortOrder);
        } else {
            $query->orderBy('created_at', 'desc');
        }

        $perPage = min($request->input('per_page', 20), 100);
        $builds = $query->paginate($perPage);

        // Transform the data
        $transformedData = [];
        foreach ($builds->items() as $build) {
            $transformedData[] = [
                'id' => $build->id,
                'share_id' => $build->share_id ?? $build->share_token,
                'share_token' => $build->share_token,
                'share_url' => $build->share_url,
                'name' => $build->build_name,
                'description' => $build->description,
                'use_case' => $build->use_case,
                'total_cost_bdt' => $build->total_cost_bdt,
                'total_price' => $build->total_cost_bdt,
                'total_tdp_w' => $build->total_tdp_w,
                'compatibility_status' => $build->compatibility_status,
                'view_count' => $build->view_count,
                'like_count' => $build->like_count,
                'comment_count' => $build->comment_count,
                'is_complete' => $build->is_complete,
                'visibility' => $build->visibility,
                'created_at' => $build->created_at,
                'updated_at' => $build->updated_at,
                'user' => $build->user ? [
                    'id' => $build->user->id,
                    'name' => $build->user->name,
                    'email' => $build->user->email,
                ] : null,
                'components' => $build->components ? $build->components->map(function($component) {
                    return [
                        'id' => $component->id,
                        'product_id' => $component->product_id,
                        'category' => $component->pivot->category ?? $component->category,
                        'name' => $component->name,
                        'brand' => $component->brand ? $component->brand->brand_name : null,
                        'price_at_selection_bdt' => $component->pivot->price_at_selection_bdt,
                        'lowest_price_bdt' => $component->lowest_price_bdt,
                        'quantity' => $component->pivot->quantity ?? 1,
                        'primary_image_url' => $component->primary_image_url,
                        'image_urls' => $component->image_urls ?? [],
                        'specs' => $component->specs_object ?? [],
                    ];
                })->values()->all() : [],
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

    /**
     * Get authenticated user's builds
     */
    public function myBuilds(Request $request)
    {
        $query = Build::with(['components.brand', 'components.specs'])
            ->where('user_id', $request->user()->id)
            ->orderBy('created_at', 'desc');

        $perPage = min($request->input('per_page', 20), 100);
        $builds = $query->paginate($perPage);

        // Transform the data
        $transformedData = [];
        foreach ($builds->items() as $build) {
            $transformedData[] = [
                'id' => $build->id,
                'share_id' => $build->share_id ?? $build->share_token,
                'share_token' => $build->share_token,
                'share_url' => $build->share_url,
                'name' => $build->build_name,
                'description' => $build->description,
                'use_case' => $build->use_case,
                'total_cost_bdt' => $build->total_cost_bdt,
                'total_price' => $build->total_cost_bdt,
                'total_tdp_w' => $build->total_tdp_w,
                'compatibility_status' => $build->compatibility_status,
                'view_count' => $build->view_count,
                'like_count' => $build->like_count,
                'visibility' => $build->visibility,
                'is_complete' => $build->is_complete,
                'created_at' => $build->created_at,
                'updated_at' => $build->updated_at,
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
                        'quantity' => $component->pivot->quantity ?? 1,
                        'specs' => $component->specs_object ?? [],
                    ];
                })->values()->all() : [],
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

    /**
     * Store a newly created build
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'build_name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'use_case' => 'nullable|in:gaming,workstation,content_creation,budget,other',
            'budget_min_bdt' => 'nullable|numeric|min:0',
            'budget_max_bdt' => 'nullable|numeric|min:0',
            'visibility' => 'nullable|in:private,public',
            'components' => 'required|array|min:1',
            'components.*.component_id' => 'required|exists:components,product_id',
            'components.*.category' => 'required|in:cpu,motherboard,gpu,ram,storage,psu,case,cooler',
            'components.*.quantity' => 'nullable|integer|min:1',
            'components.*.price_at_selection_bdt' => 'nullable|numeric|min:0',
        ]);

        // Calculate total cost
        $totalCost = 0;
        foreach ($validated['components'] as $comp) {
            $price = $comp['price_at_selection_bdt'] ?? 0;
            $quantity = $comp['quantity'] ?? 1;
            $totalCost += $price * $quantity;
        }

        // Create build
        $build = Build::create([
            'user_id' => $request->user()->id,
            'build_name' => $validated['build_name'],
            'description' => $validated['description'] ?? null,
            'use_case' => $validated['use_case'] ?? null,
            'budget_min_bdt' => $validated['budget_min_bdt'] ?? null,
            'budget_max_bdt' => $validated['budget_max_bdt'] ?? null,
            'total_cost_bdt' => $totalCost,
            'total_price' => $totalCost, // Legacy field
            'visibility' => $validated['visibility'] ?? 'private',
            'compatibility_status' => 'valid', // TODO: Add compatibility check
            'is_complete' => true,
        ]);

        // Attach components (convert product_id to actual id)
        foreach ($validated['components'] as $comp) {
            $component = Component::where('product_id', $comp['component_id'])->first();
            if ($component) {
                $build->components()->attach($component->id, [
                    'category' => $comp['category'],
                    'quantity' => $comp['quantity'] ?? 1,
                    'price_at_selection_bdt' => $comp['price_at_selection_bdt'] ?? null,
                ]);
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Build created successfully',
            'data' => $build->load('components.brand')
        ], 201);
    }

    /**
     * Display the specified build
     */
    public function show($id)
    {
        $build = Build::with(['user', 'components.brand', 'components.specs', 'components.prices'])
            ->find($id);

        if (!$build) {
            return response()->json([
                'success' => false,
                'message' => 'Build not found'
            ], 404);
        }

        // Increment view count
        $build->increment('view_count');
        $build->increment('views'); // Legacy field

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $build->id,
                'share_id' => $build->share_id,
                'share_token' => $build->share_token,
                'share_url' => $build->share_url,
                'name' => $build->build_name,
                'description' => $build->description,
                'use_case' => $build->use_case,
                'total_cost_bdt' => $build->total_cost_bdt,
                'total_tdp_w' => $build->total_tdp_w,
                'compatibility_status' => $build->compatibility_status,
                'compatibility_issues' => $build->compatibility_issues,
                'view_count' => $build->view_count,
                'like_count' => $build->like_count,
                'comment_count' => $build->comment_count,
                'visibility' => $build->visibility,
                'is_complete' => $build->is_complete,
                'created_at' => $build->created_at,
                'updated_at' => $build->updated_at,
                'user' => $build->user ? [
                    'id' => $build->user->id,
                    'name' => $build->user->name,
                    'email' => $build->user->email,
                ] : null,
                'components' => $build->components ? $build->components->map(function($component) {
                    return [
                        'id' => $component->id,
                        'product_id' => $component->product_id,
                        'category' => $component->pivot->category,
                        'name' => $component->name,
                        'brand' => $component->brand ? $component->brand->brand_name : null,
                        'slug' => $component->slug,
                        'primary_image_url' => $component->primary_image_url,
                        'image_urls' => $component->image_urls ?? [],
                        'lowest_price_bdt' => $component->lowest_price_bdt,
                        'price_at_selection_bdt' => $component->pivot->price_at_selection_bdt,
                        'quantity' => $component->pivot->quantity,
                        'specs' => $component->specs_object,
                        'prices' => $component->prices,
                    ];
                })->values()->all() : [],
            ]
        ]);
    }

    /**
     * Update the specified build
     */
    public function update(Request $request, $id)
    {
        $build = Build::find($id);

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
            'build_name' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'use_case' => 'nullable|in:gaming,workstation,content_creation,budget,other',
            'budget_min_bdt' => 'nullable|numeric|min:0',
            'budget_max_bdt' => 'nullable|numeric|min:0',
            'visibility' => 'nullable|in:private,public',
            'components' => 'sometimes|array|min:1',
            'components.*.component_id' => 'required_with:components|exists:components,product_id',
            'components.*.category' => 'required_with:components|in:cpu,motherboard,gpu,ram,storage,psu,case,cooler',
            'components.*.quantity' => 'nullable|integer|min:1',
            'components.*.price_at_selection_bdt' => 'nullable|numeric|min:0',
        ]);

        // Update build fields
        $build->fill($validated);

        // Update components if provided
        if (isset($validated['components'])) {
            // Calculate new total cost
            $totalCost = 0;
            foreach ($validated['components'] as $comp) {
                $price = $comp['price_at_selection_bdt'] ?? 0;
                $quantity = $comp['quantity'] ?? 1;
                $totalCost += $price * $quantity;
            }
            $build->total_cost_bdt = $totalCost;
            $build->total_price = $totalCost; // Legacy

            // Sync components (convert product_id to actual id)
            $syncData = [];
            foreach ($validated['components'] as $comp) {
                $component = Component::where('product_id', $comp['component_id'])->first();
                if ($component) {
                    $syncData[$component->id] = [
                        'category' => $comp['category'],
                        'quantity' => $comp['quantity'] ?? 1,
                        'price_at_selection_bdt' => $comp['price_at_selection_bdt'] ?? null,
                    ];
                }
            }
            $build->components()->sync($syncData);
        }

        $build->save();

        return response()->json([
            'success' => true,
            'message' => 'Build updated successfully',
            'data' => $build->load('components.brand')
        ]);
    }

    /**
     * Remove the specified build
     */
    public function destroy(Request $request, $id)
    {
        $build = Build::find($id);

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

        $build->delete();

        return response()->json([
            'success' => true,
            'message' => 'Build deleted successfully'
        ]);
    }

    /**
     * Toggle like on a build
     */
    public function toggleLike(Request $request, $id)
    {
        $build = Build::find($id);

        if (!$build) {
            return response()->json([
                'success' => false,
                'message' => 'Build not found'
            ], 404);
        }

        // Check if user already liked
        $existingLike = DB::table('build_likes')
            ->where('build_id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        if ($existingLike) {
            // Unlike
            DB::table('build_likes')
                ->where('build_id', $id)
                ->where('user_id', $request->user()->id)
                ->delete();
            $build->decrement('like_count');
            $liked = false;
        } else {
            // Like
            DB::table('build_likes')->insert([
                'build_id' => $id,
                'user_id' => $request->user()->id,
                'created_at' => now(),
            ]);
            $build->increment('like_count');
            $liked = true;
        }

        return response()->json([
            'success' => true,
            'liked' => $liked,
            'like_count' => $build->fresh()->like_count
        ]);
    }

    /**
     * Add comment to a build
     */
    public function addComment(Request $request, $id)
    {
        $build = Build::find($id);

        if (!$build) {
            return response()->json([
                'success' => false,
                'message' => 'Build not found'
            ], 404);
        }

        $validated = $request->validate([
            'comment' => 'required|string|max:1000'
        ]);

        $commentId = DB::table('build_comments')->insertGetId([
            'build_id' => $id,
            'user_id' => $request->user()->id,
            'comment' => $validated['comment'],
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $build->increment('comment_count');

        $comment = DB::table('build_comments')
            ->leftJoin('users', 'build_comments.user_id', '=', 'users.id')
            ->where('build_comments.id', $commentId)
            ->select('build_comments.*', 'users.name as user_name')
            ->first();

        return response()->json([
            'success' => true,
            'message' => 'Comment added successfully',
            'data' => $comment
        ], 201);
    }

    /**
     * Get comments for a build
     */
    public function getComments($id)
    {
        $comments = DB::table('build_comments')
            ->leftJoin('users', 'build_comments.user_id', '=', 'users.id')
            ->where('build_comments.build_id', $id)
            ->select(
                'build_comments.*',
                'users.name as user_name',
                'users.email as user_email'
            )
            ->orderBy('build_comments.created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $comments
        ]);
    }
}
