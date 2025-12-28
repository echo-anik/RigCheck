<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Laravel\Socialite\Facades\Socialite;
use Exception;

class SocialAuthController extends Controller
{
    /**
     * Redirect to Google OAuth provider
     * For mobile apps, this returns the redirect URL instead of redirecting
     */
    public function redirectToGoogle(Request $request)
    {
        try {
            // For mobile apps, return the authorization URL
            $redirectUrl = Socialite::driver('google')
                ->stateless()
                ->redirect()
                ->getTargetUrl();

            return response()->json([
                'success' => true,
                'data' => [
                    'url' => $redirectUrl
                ],
                'message' => 'Google OAuth URL generated successfully'
            ]);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate Google OAuth URL',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Handle Google OAuth callback
     * This will work with mobile deep links
     */
    public function handleGoogleCallback(Request $request)
    {
        try {
            // Get user info from Google
            $googleUser = Socialite::driver('google')
                ->stateless()
                ->user();

            // Find or create user
            $user = User::where('google_id', $googleUser->getId())
                ->orWhere('email', $googleUser->getEmail())
                ->first();

            if ($user) {
                // Update google_id if user exists but doesn't have it
                if (!$user->google_id) {
                    $user->update(['google_id' => $googleUser->getId()]);
                }

                // Check if user is banned
                if ($user->is_banned) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Your account has been banned.'
                    ], 403);
                }
            } else {
                // Create new user
                $user = User::create([
                    'name' => $googleUser->getName(),
                    'email' => $googleUser->getEmail(),
                    'google_id' => $googleUser->getId(),
                    'password' => Hash::make(Str::random(32)), // Random password for OAuth users
                    'role' => 'user',
                    'avatar_url' => $googleUser->getAvatar(),
                    'email_verified_at' => now(), // Google users are already verified
                ]);
            }

            // Create API token (JWT-like token using Sanctum)
            $token = $user->createToken('api-token')->plainTextToken;

            return response()->json([
                'success' => true,
                'data' => [
                    'user' => $user,
                    'token' => $token
                ],
                'message' => 'Login successful'
            ]);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Authentication failed',
                'error' => $e->getMessage()
            ], 401);
        }
    }

    /**
     * Handle Google OAuth callback for mobile apps with code exchange
     * Mobile apps can send the authorization code to this endpoint
     */
    public function handleGoogleCallbackWithCode(Request $request)
    {
        try {
            $request->validate([
                'code' => 'required|string',
            ]);

            // Exchange code for access token and get user info
            $googleUser = Socialite::driver('google')
                ->stateless()
                ->user();

            // Find or create user
            $user = User::where('google_id', $googleUser->getId())
                ->orWhere('email', $googleUser->getEmail())
                ->first();

            if ($user) {
                // Update google_id if user exists but doesn't have it
                if (!$user->google_id) {
                    $user->update(['google_id' => $googleUser->getId()]);
                }

                // Check if user is banned
                if ($user->is_banned) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Your account has been banned.'
                    ], 403);
                }
            } else {
                // Create new user
                $user = User::create([
                    'name' => $googleUser->getName(),
                    'email' => $googleUser->getEmail(),
                    'google_id' => $googleUser->getId(),
                    'password' => Hash::make(Str::random(32)), // Random password for OAuth users
                    'role' => 'user',
                    'avatar_url' => $googleUser->getAvatar(),
                    'email_verified_at' => now(), // Google users are already verified
                ]);
            }

            // Create API token (JWT-like token using Sanctum)
            $token = $user->createToken('api-token')->plainTextToken;

            return response()->json([
                'success' => true,
                'data' => [
                    'user' => $user,
                    'token' => $token
                ],
                'message' => 'Login successful'
            ]);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Authentication failed',
                'error' => $e->getMessage()
            ], 401);
        }
    }
}
