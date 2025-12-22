<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Intervention\Image\Facades\Image;

class ImageUploadController extends Controller
{
    /**
     * Upload component image
     */
    public function uploadComponentImage(Request $request)
    {
        $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg,webp|max:5120', // 5MB max
            'component_id' => 'required|exists:components,id',
        ]);

        try {
            $file = $request->file('image');
            $componentId = $request->component_id;

            // Generate unique filename
            $filename = 'component_' . $componentId . '_' . time() . '.' . $file->getClientOriginalExtension();
            $path = 'components/' . $filename;

            // Optimize and resize image
            $image = Image::make($file)
                ->resize(800, 800, function ($constraint) {
                    $constraint->aspectRatio();
                    $constraint->upsize();
                })
                ->encode($file->getClientOriginalExtension(), 85);

            // Store optimized image
            Storage::disk('public')->put($path, $image);

            // Generate thumbnail
            $thumbnailPath = 'components/thumbnails/' . $filename;
            $thumbnail = Image::make($file)
                ->fit(200, 200)
                ->encode($file->getClientOriginalExtension(), 75);
            Storage::disk('public')->put($thumbnailPath, $thumbnail);

            // Update component record
            $component = \App\Models\Component::find($componentId);
            $component->primary_image_url = Storage::url($path);
            $component->thumbnail_url = Storage::url($thumbnailPath);
            $component->save();

            return response()->json([
                'success' => true,
                'message' => 'Image uploaded successfully',
                'data' => [
                    'image_url' => Storage::url($path),
                    'thumbnail_url' => Storage::url($thumbnailPath),
                ]
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'IMAGE_UPLOAD_FAILED',
                    'message' => 'Failed to upload image: ' . $e->getMessage(),
                ]
            ], 500);
        }
    }

    /**
     * Upload user avatar
     */
    public function uploadAvatar(Request $request)
    {
        $request->validate([
            'avatar' => 'required|image|mimes:jpeg,png,jpg|max:2048', // 2MB max
        ]);

        try {
            $file = $request->file('avatar');
            $userId = $request->user()->id;

            // Delete old avatar if exists
            if ($request->user()->avatar_url) {
                $oldPath = str_replace('/storage/', '', parse_url($request->user()->avatar_url, PHP_URL_PATH));
                Storage::disk('public')->delete($oldPath);
            }

            // Generate unique filename
            $filename = 'avatar_' . $userId . '_' . time() . '.' . $file->getClientOriginalExtension();
            $path = 'avatars/' . $filename;

            // Create square avatar (300x300)
            $image = Image::make($file)
                ->fit(300, 300)
                ->encode($file->getClientOriginalExtension(), 85);

            // Store avatar
            Storage::disk('public')->put($path, $image);

            // Update user record
            $user = $request->user();
            $user->avatar_url = Storage::url($path);
            $user->save();

            return response()->json([
                'success' => true,
                'message' => 'Avatar uploaded successfully',
                'data' => [
                    'avatar_url' => Storage::url($path),
                ]
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'AVATAR_UPLOAD_FAILED',
                    'message' => 'Failed to upload avatar: ' . $e->getMessage(),
                ]
            ], 500);
        }
    }

    /**
     * Upload build image/screenshot
     */
    public function uploadBuildImage(Request $request)
    {
        $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg,webp|max:10240', // 10MB max
            'build_id' => 'required|exists:builds,id',
        ]);

        try {
            $file = $request->file('image');
            $buildId = $request->build_id;

            // Verify ownership
            $build = \App\Models\Build::findOrFail($buildId);
            if ($build->user_id !== $request->user()->id) {
                return response()->json([
                    'success' => false,
                    'error' => [
                        'code' => 'UNAUTHORIZED',
                        'message' => 'You do not own this build',
                    ]
                ], 403);
            }

            // Generate unique filename
            $filename = 'build_' . $buildId . '_' . time() . '.' . $file->getClientOriginalExtension();
            $path = 'builds/' . $filename;

            // Optimize and resize image
            $image = Image::make($file)
                ->resize(1200, 1200, function ($constraint) {
                    $constraint->aspectRatio();
                    $constraint->upsize();
                })
                ->encode($file->getClientOriginalExtension(), 85);

            // Store optimized image
            Storage::disk('public')->put($path, $image);

            // Generate thumbnail
            $thumbnailPath = 'builds/thumbnails/' . $filename;
            $thumbnail = Image::make($file)
                ->fit(400, 300)
                ->encode($file->getClientOriginalExtension(), 75);
            Storage::disk('public')->put($thumbnailPath, $thumbnail);

            // Update build record (assuming you add image_url field to builds table)
            $build->image_url = Storage::url($path);
            $build->thumbnail_url = Storage::url($thumbnailPath);
            $build->save();

            return response()->json([
                'success' => true,
                'message' => 'Build image uploaded successfully',
                'data' => [
                    'image_url' => Storage::url($path),
                    'thumbnail_url' => Storage::url($thumbnailPath),
                ]
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'BUILD_IMAGE_UPLOAD_FAILED',
                    'message' => 'Failed to upload build image: ' . $e->getMessage(),
                ]
            ], 500);
        }
    }

    /**
     * Delete image
     */
    public function deleteImage(Request $request)
    {
        $request->validate([
            'image_url' => 'required|string',
            'type' => 'required|in:component,avatar,build',
        ]);

        try {
            $imageUrl = $request->image_url;
            $type = $request->type;

            // Extract path from URL
            $path = str_replace('/storage/', '', parse_url($imageUrl, PHP_URL_PATH));

            // Verify ownership/permissions
            if ($type === 'avatar') {
                if ($request->user()->avatar_url !== $imageUrl) {
                    return response()->json([
                        'success' => false,
                        'error' => ['code' => 'UNAUTHORIZED', 'message' => 'Not your avatar'],
                    ], 403);
                }
            }

            // Delete file
            if (Storage::disk('public')->exists($path)) {
                Storage::disk('public')->delete($path);

                // Delete thumbnail if exists
                $thumbnailPath = str_replace($type . 's/', $type . 's/thumbnails/', $path);
                if (Storage::disk('public')->exists($thumbnailPath)) {
                    Storage::disk('public')->delete($thumbnailPath);
                }
            }

            return response()->json([
                'success' => true,
                'message' => 'Image deleted successfully',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'IMAGE_DELETE_FAILED',
                    'message' => 'Failed to delete image: ' . $e->getMessage(),
                ]
            ], 500);
        }
    }
}
