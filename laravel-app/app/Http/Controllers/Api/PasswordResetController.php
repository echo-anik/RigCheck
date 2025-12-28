<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use App\Models\User;

class PasswordResetController extends Controller
{
    /**
     * Send password reset link
     */
    public function sendResetLink(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:users,email',
        ]);

        $user = User::where('email', $request->email)->first();

        // Generate reset token
        $token = Str::random(64);
        $user->password_reset_token = hash('sha256', $token);
        $user->password_reset_expires_at = now()->addHours(1);
        $user->save();

        // Create reset URL
        $resetUrl = url("/reset-password?token={$token}&email={$user->email}");

        // Send email
        try {
            Mail::raw(
                "Click here to reset your password: {$resetUrl}\n\nThis link will expire in 1 hour.",
                function ($message) use ($user) {
                    $message->to($user->email)
                        ->subject('Reset Your Password - RigCheck');
                }
            );

            return response()->json([
                'success' => true,
                'message' => 'Password reset link sent to your email',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'EMAIL_SEND_FAILED',
                    'message' => 'Failed to send reset email',
                ]
            ], 500);
        }
    }

    /**
     * Reset password with token
     */
    public function resetPassword(Request $request)
    {
        $request->validate([
            'token' => 'required|string',
            'email' => 'required|email',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $hashedToken = hash('sha256', $request->token);

        $user = User::where('email', $request->email)
            ->where('password_reset_token', $hashedToken)
            ->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'INVALID_TOKEN',
                    'message' => 'Invalid or expired reset token',
                ]
            ], 400);
        }

        // Check if token expired
        if ($user->password_reset_expires_at < now()) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'TOKEN_EXPIRED',
                    'message' => 'Reset token has expired',
                ]
            ], 400);
        }

        // Update password
        $user->password = Hash::make($request->password);
        $user->password_reset_token = null;
        $user->password_reset_expires_at = null;
        $user->save();

        // Revoke all tokens for security
        $user->tokens()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Password reset successfully',
        ]);
    }

    /**
     * Validate reset token
     */
    public function validateToken(Request $request)
    {
        $request->validate([
            'token' => 'required|string',
            'email' => 'required|email',
        ]);

        $hashedToken = hash('sha256', $request->token);

        $user = User::where('email', $request->email)
            ->where('password_reset_token', $hashedToken)
            ->first();

        if (!$user || $user->password_reset_expires_at < now()) {
            return response()->json([
                'success' => false,
                'valid' => false,
                'message' => 'Invalid or expired token',
            ]);
        }

        return response()->json([
            'success' => true,
            'valid' => true,
            'message' => 'Token is valid',
        ]);
    }
}
