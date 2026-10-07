<?php

use App\Http\Controllers\Api\App\AuthController;
use App\Http\Controllers\Api\App\BuildController;
use App\Http\Controllers\Api\App\ComponentController;
use App\Http\Controllers\Api\App\CompatibilityController;
use App\Http\Controllers\Api\App\ImageUploadController;
use App\Http\Controllers\Api\App\EmailVerificationController;
use App\Http\Controllers\Api\App\PasswordResetController;
use App\Http\Controllers\Api\App\SharedBuildController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Authentication endpoints
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
Route::get('/user', [AuthController::class, 'user'])->middleware('auth:sanctum');

// Components - Public endpoints
Route::get('/components', [ComponentController::class, 'index']);
Route::get('/components/stats/counts', [ComponentController::class, 'getCategoryCounts']);
Route::get('/components/{productId}', [ComponentController::class, 'show']);

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
