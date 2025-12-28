<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Post;
use Illuminate\Http\Request;

class AdminPostController extends Controller
{
    /**
     * Get all posts
     */
    public function index(Request $request)
    {
        $query = Post::with(['user'])->withCount(['likes', 'comments']);

        // Search
        if ($request->has('search')) {
            $query->where('content', 'like', '%' . $request->search . '%');
        }

        // Filter by featured
        if ($request->has('is_featured')) {
            $query->where('is_featured', $request->is_featured);
        }

        $posts = $query->latest()->paginate($request->input('per_page', 50));

        return response()->json($posts);
    }

    /**
     * Toggle featured status
     */
    public function toggleFeatured($id)
    {
        $post = Post::findOrFail($id);
        $post->is_featured = !$post->is_featured;
        $post->save();

        return response()->json([
            'success' => true,
            'message' => $post->is_featured ? 'Post featured' : 'Post unfeatured',
            'data' => $post,
        ]);
    }

    /**
     * Delete post
     */
    public function destroy($id)
    {
        $post = Post::findOrFail($id);
        $post->delete();

        return response()->json([
            'success' => true,
            'message' => 'Post deleted successfully',
        ]);
    }
}
