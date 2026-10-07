<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group.
|
*/

// Web Application Endpoints
Route::prefix('v1/web')->group(base_path('routes/web_api.php'));

// Mobile Application Endpoints
Route::prefix('v1/app')->group(base_path('routes/app_api.php'));
