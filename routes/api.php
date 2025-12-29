<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\SocialAuthController;
use App\Http\Controllers\Api\BuildController;
use App\Http\Controllers\Api\ComponentController;
use App\Http\Controllers\Api\CompatibilityController;
use App\Http\Controllers\Api\ImageUploadController;
use App\Http\Controllers\Api\EmailVerificationController;
use App\Http\Controllers\Api\PasswordResetController;
use App\Http\Controllers\Api\PostController;
use App\Http\Controllers\Api\LikeController;
use App\Http\Controllers\Api\FollowController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\SharedBuildController;
use App\Http\Controllers\Api\Admin\AdminDashboardController;
use App\Http\Controllers\Api\Admin\AdminUserController;
use App\Http\Controllers\Api\Admin\AdminPostController;
use App\Http\Controllers\Api\Admin\AdminComponentController;
use App\Http\Controllers\Api\Admin\AdminBuildController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// API Version 1
Route::prefix('v1')->group(function () {
    
    // Authentication endpoints
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
    Route::get('/user', [AuthController::class, 'user'])->middleware('auth:sanctum');

    // Google OAuth endpoints
    Route::get('/auth/google/redirect', [SocialAuthController::class, 'redirectToGoogle']);
    Route::get('/auth/google/callback', [SocialAuthController::class, 'handleGoogleCallback']);
    Route::post('/auth/google/callback', [SocialAuthController::class, 'handleGoogleCallbackWithCode']);

    // Components - Public endpoints
    Route::get('/components', [ComponentController::class, 'index']);
    Route::get('/components/stats/counts', [ComponentController::class, 'getCategoryCounts']);
    Route::get('/components/{productId}', [ComponentController::class, 'show']);

    // Components - Admin endpoints (protected)
    Route::middleware(['auth:sanctum', \App\Http\Middleware\AdminMiddleware::class])->group(function () {
        Route::post('/components', [ComponentController::class, 'store']);
        Route::put('/components/{id}', [ComponentController::class, 'update']);
        Route::delete('/components/{id}', [ComponentController::class, 'destroy']);
    });

    // Compatibility validation
    Route::post('/builds/validate', [CompatibilityController::class, 'check']);
    Route::get('/rules', [CompatibilityController::class, 'getRules']);

    // Builds - Protected endpoints (MUST come before {id} routes!)
    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/builds/my', [BuildController::class, 'myBuilds']);
        Route::post('/builds', [BuildController::class, 'store']);
        Route::put('/builds/{id}', [BuildController::class, 'update']);
        Route::delete('/builds/{id}', [BuildController::class, 'destroy']);
        Route::post('/builds/{id}/like', [BuildController::class, 'toggleLike']);
        Route::post('/builds/{id}/comment', [BuildController::class, 'addComment']);
    });

    // Builds - Public endpoints (After protected routes to avoid conflicts)
    Route::get('/builds/public', [BuildController::class, 'publicBuilds']);
    Route::get('/builds/{id}', [BuildController::class, 'show']);
    Route::get('/builds/{id}/comments', [BuildController::class, 'getComments']);

    // Shared builds - Public endpoints
    Route::get('/shared-builds', [SharedBuildController::class, 'index']);
    Route::get('/shared-builds/{shareToken}', [SharedBuildController::class, 'show']);
    Route::post('/shared-builds', [SharedBuildController::class, 'store']);

    // Image Upload endpoints - Protected
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/images/component', [ImageUploadController::class, 'uploadComponentImage']);
        Route::post('/images/avatar', [ImageUploadController::class, 'uploadAvatar']);
        Route::post('/images/build', [ImageUploadController::class, 'uploadBuildImage']);
        Route::delete('/images', [ImageUploadController::class, 'deleteImage']);
    });

    // Email Verification endpoints
    Route::post('/email/send-verification', [EmailVerificationController::class, 'sendVerificationEmail'])->middleware('auth:sanctum');
    Route::get('/email/verify/{token}', [EmailVerificationController::class, 'verifyEmail']);
    Route::get('/email/verification-status', [EmailVerificationController::class, 'checkVerificationStatus'])->middleware('auth:sanctum');

    // Password Reset endpoints
    Route::post('/password/send-reset-link', [PasswordResetController::class, 'sendResetLink']);
    Route::post('/password/reset', [PasswordResetController::class, 'resetPassword']);
    Route::post('/password/validate-token', [PasswordResetController::class, 'validateToken']);

    // Admin - Protected endpoints (admin only)
    Route::middleware(['auth:sanctum', 'admin'])->prefix('admin')->group(function () {
        // Dashboard
        Route::get('/stats', [AdminDashboardController::class, 'stats']);
        
        // Users Management
        Route::get('/users', [AdminUserController::class, 'index']);
        Route::get('/users/{id}', [AdminUserController::class, 'show']);
        Route::put('/users/{id}', [AdminUserController::class, 'update']);
        Route::delete('/users/{id}', [AdminUserController::class, 'destroy']);
        
        // Components Management (Admin CRUD)
        Route::get('/components', [AdminComponentController::class, 'index']);
        Route::post('/components', [AdminComponentController::class, 'store']);
        Route::get('/components/{id}', [AdminComponentController::class, 'show']);
        Route::put('/components/{id}', [AdminComponentController::class, 'update']);
        Route::delete('/components/{id}', [AdminComponentController::class, 'destroy']);
        Route::get('/components/stats', [AdminComponentController::class, 'stats']);

        // Builds Management (Admin CRUD)
        Route::get('/builds', [AdminBuildController::class, 'index']);
        Route::get('/builds/stats', [AdminBuildController::class, 'stats']);
        Route::get('/builds/{id}', [AdminBuildController::class, 'show']);
        Route::put('/builds/{id}', [AdminBuildController::class, 'update']);
        Route::patch('/builds/{id}/visibility', [AdminBuildController::class, 'toggleVisibility']);
        Route::delete('/builds/{id}', [AdminBuildController::class, 'destroy']);
    });
});
