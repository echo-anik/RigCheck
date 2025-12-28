<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Build;
use App\Models\Component;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminDashboardController extends Controller
{
    /**
     * Get dashboard statistics
     */
    public function stats()
    {
        $stats = [
            'total_users' => User::count(),
            'total_components' => Component::count(),
            'total_builds' => Build::count(),
            'public_builds' => Build::where('is_public', true)->count(),
            'featured_components' => Component::where('featured', true)->count(),
            'banned_users' => User::where('is_banned', true)->count(),
            'new_users_this_month' => User::whereMonth('created_at', now()->month)->count(),
            'components_by_category' => Component::select('category', DB::raw('count(*) as count'))
                ->groupBy('category')
                ->get(),
            'recent_users' => User::latest()->limit(10)->get(['id', 'name', 'email', 'created_at', 'role']),
            'recent_builds' => Build::with('user:id,name')->latest()->limit(10)->get(),
        ];

        return response()->json([
            'success' => true,
            'data' => $stats,
        ]);
    }
}
