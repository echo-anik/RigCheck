<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use App\Models\User;

class EmailVerificationController extends Controller
{
    /**
     * Send email verification link
     */
    public function sendVerificationEmail(Request $request)
    {
        $user = $request->user();

        if ($user->email_verified_at) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'ALREADY_VERIFIED',
                    'message' => 'Email is already verified',
                ]
            ], 400);
        }

        // Generate verification token
        $token = Str::random(64);
        $user->verification_token = hash('sha256', $token);
        $user->save();

        // Create verification URL
        $verificationUrl = url("/api/v1/email/verify/{$token}");

        // Send email (simplified - you'd use a proper mail template)
        try {
            Mail::raw(
                "Click here to verify your email: {$verificationUrl}",
                function ($message) use ($user) {
                    $message->to($user->email)
                        ->subject('Verify Your Email - RigCheck');
                }
            );

            return response()->json([
                'success' => true,
                'message' => 'Verification email sent successfully',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'EMAIL_SEND_FAILED',
                    'message' => 'Failed to send verification email',
                ]
            ], 500);
        }
    }

    /**
     * Verify email with token
     */
    public function verifyEmail($token)
    {
        $hashedToken = hash('sha256', $token);
        $user = User::where('verification_token', $hashedToken)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'INVALID_TOKEN',
                    'message' => 'Invalid or expired verification token',
                ]
            ], 400);
        }

        if ($user->email_verified_at) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'ALREADY_VERIFIED',
                    'message' => 'Email is already verified',
                ]
            ], 400);
        }

        // Mark email as verified
        $user->email_verified_at = now();
        $user->verification_token = null;
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Email verified successfully',
        ]);
    }

    /**
     * Check verification status
     */
    public function checkVerificationStatus(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'success' => true,
            'data' => [
                'is_verified' => $user->email_verified_at !== null,
                'verified_at' => $user->email_verified_at,
            ]
        ]);
    }
}
