<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ComponentController;
use App\Http\Controllers\Api\BuildController;
use App\Http\Controllers\Api\CompatibilityController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| RigCheck PC Compatibility Checker API
| Version: 1.0
|
*/

// Health check
Route::get('/health', function () {
    return response()->json([
        'success' => true,
        'data' => [
            'status' => 'healthy',
            'version' => '1.0.0',
            'timestamp' => now()->toIso8601String(),
        ]
    ]);
});

// API Version 1
Route::prefix('v1')->group(function () {

    // ========================================================================
    // AUTHENTICATION ROUTES
    // ========================================================================
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);

    // Protected auth routes
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/user', [AuthController::class, 'user']);
    });

    // ========================================================================
    // COMPONENT ROUTES (Public)
    // ========================================================================
    Route::prefix('components')->group(function () {
        Route::get('/', [ComponentController::class, 'index']);
        Route::get('/featured', [ComponentController::class, 'featured']);
        Route::get('/search', [ComponentController::class, 'search']);
        Route::get('/category/{category}', [ComponentController::class, 'byCategory']);
        Route::get('/{id}', [ComponentController::class, 'show']);
    });

    // ========================================================================
    // COMPATIBILITY ROUTES
    // ========================================================================
    Route::prefix('compatibility')->group(function () {
        Route::get('/rules', [CompatibilityController::class, 'rules']);
        Route::post('/validate', [CompatibilityController::class, 'validate']);
        Route::get('/motherboards/{cpuId}', [CompatibilityController::class, 'compatibleMotherboards']);
    });

    // ========================================================================
    // BUILD ROUTES
    // ========================================================================
    Route::prefix('builds')->group(function () {
        // Public routes
        Route::get('/public', [BuildController::class, 'publicBuilds']);
        Route::get('/{shareToken}', [BuildController::class, 'showByToken']);

        // Protected routes
        Route::middleware('auth:sanctum')->group(function () {
            Route::get('/my', [BuildController::class, 'myBuilds']);
            Route::post('/', [BuildController::class, 'store']);
            Route::get('/id/{id}', [BuildController::class, 'show']);
            Route::put('/{id}', [BuildController::class, 'update']);
            Route::delete('/{id}', [BuildController::class, 'destroy']);

            // Social actions
            Route::post('/{id}/like', [BuildController::class, 'like']);
            Route::delete('/{id}/unlike', [BuildController::class, 'unlike']);
            Route::post('/{id}/comment', [BuildController::class, 'comment']);
        });
    });

    // ========================================================================
    // SYNC ROUTES (For Mobile App)
    // ========================================================================
    Route::prefix('sync')->group(function () {
        Route::get('/components', [ComponentController::class, 'syncComponents']);
        Route::get('/rules', [CompatibilityController::class, 'syncRules']);

        Route::middleware('auth:sanctum')->group(function () {
            Route::get('/builds', [BuildController::class, 'syncBuilds']);
        });
    });

    // ========================================================================
    // STATISTICS & METADATA
    // ========================================================================
    Route::get('/stats', function () {
        return response()->json([
            'success' => true,
            'data' => [
                'total_components' => \App\Models\Component::count(),
                'total_builds' => \App\Models\Build::count(),
                'total_users' => \App\Models\User::count(),
                'components_by_category' => \App\Models\Component::selectRaw('category, COUNT(*) as count')
                    ->groupBy('category')
                    ->get()
                    ->pluck('count', 'category'),
            ]
        ]);
    });
});

// Catch-all for undefined routes
Route::fallback(function () {
    return response()->json([
        'success' => false,
        'error' => [
            'code' => 'ROUTE_NOT_FOUND',
            'message' => 'The requested API endpoint does not exist.',
        ]
    ], 404);
});
