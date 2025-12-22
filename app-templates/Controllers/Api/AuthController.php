<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Register a new user.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function register(Request $request): JsonResponse
    {
        $request->validate([
            'username' => 'required|string|max:100|unique:users',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'display_name' => 'nullable|string|max:200',
        ]);

        $user = User::create([
            'username' => $request->username,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'display_name' => $request->display_name ?? $request->username,
            'is_verified' => false,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'data' => [
                'user' => $this->transformUser($user),
                'token' => $token,
                'token_type' => 'Bearer',
            ],
            'message' => 'User registered successfully',
        ], 201);
    }

    /**
     * Login user and create token.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        // Check if user is banned
        if ($user->is_banned) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'USER_BANNED',
                    'message' => 'Your account has been banned.',
                    'details' => [
                        'reason' => $user->ban_reason,
                        'expires_at' => $user->ban_expires_at,
                    ]
                ]
            ], 403);
        }

        // Revoke old tokens
        $user->tokens()->delete();

        // Create new token
        $token = $user->createToken('auth_token')->plainTextToken;

        // Update last login
        $user->update([
            'last_login' => now(),
            'login_count' => $user->login_count + 1,
        ]);

        return response()->json([
            'success' => true,
            'data' => [
                'user' => $this->transformUser($user),
                'token' => $token,
                'token_type' => 'Bearer',
            ],
            'message' => 'Login successful',
        ]);
    }

    /**
     * Logout user (revoke token).
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully',
        ]);
    }

    /**
     * Get authenticated user.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function user(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'success' => true,
            'data' => [
                'user' => $this->transformUser($user),
            ]
        ]);
    }

    /**
     * Transform user data for API response.
     *
     * @param  \App\Models\User  $user
     * @return array
     */
    private function transformUser($user): array
    {
        return [
            'id' => $user->id,
            'username' => $user->username,
            'email' => $user->email,
            'display_name' => $user->display_name,
            'avatar_url' => $user->avatar_url,
            'bio' => $user->bio,
            'location_city' => $user->location_city,
            'role' => $user->role,
            'is_verified' => $user->is_verified,
            'build_count' => $user->build_count,
            'total_likes_received' => $user->total_likes_received,
            'created_at' => $user->created_at->toIso8601String(),
        ];
    }
}
