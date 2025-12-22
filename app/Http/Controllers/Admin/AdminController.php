<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Component;
use App\Models\Build;
use App\Models\User;
use App\Models\BuildComment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminController extends Controller
{
    /**
     * Display admin dashboard
     */
    public function dashboard()
    {
        // Get statistics
        $stats = [
            'total_components' => Component::count(),
            'total_builds' => Build::count(),
            'total_users' => User::count(),
            'total_comments' => BuildComment::count(),
            'public_builds' => Build::where('is_public', true)->count(),
            'featured_components' => Component::where('featured', true)->count(),
            'components_by_category' => Component::select('category', DB::raw('count(*) as count'))
                ->groupBy('category')
                ->get(),
            'recent_builds' => Build::with('user')->latest()->limit(10)->get(),
            'recent_users' => User::latest()->limit(10)->get(),
        ];

        return view('admin.dashboard', $stats);
    }

    /**
     * Components management index
     */
    public function components(Request $request)
    {
        $query = Component::with('brand');

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('sku', 'like', "%{$search}%");
            });
        }

        // Filter by category
        if ($request->has('category') && $request->category != 'all') {
            $query->where('category', $request->category);
        }

        // Filter by availability
        if ($request->has('availability')) {
            $query->where('availability_status', $request->availability);
        }

        $components = $query->paginate(50);

        return view('admin.components.index', compact('components'));
    }

    /**
     * Show component edit form
     */
    public function editComponent($id)
    {
        $component = Component::with(['brand', 'specs', 'prices'])->findOrFail($id);
        return view('admin.components.edit', compact('component'));
    }

    /**
     * Update component
     */
    public function updateComponent(Request $request, $id)
    {
        $component = Component::findOrFail($id);

        $validated = $request->validate([
            'name' => 'required|string|max:500',
            'category' => 'required|string',
            'brand_id' => 'nullable|exists:brands,id',
            'price_bdt' => 'nullable|numeric',
            'availability_status' => 'required|in:in_stock,out_of_stock,discontinued',
            'featured' => 'boolean',
        ]);

        $component->update($validated);

        return redirect()->route('admin.components')
            ->with('success', 'Component updated successfully');
    }

    /**
     * Builds management index
     */
    public function builds(Request $request)
    {
        $query = Build::with(['user', 'components']);

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where('build_name', 'like', "%{$search}%");
        }

        // Filter by visibility
        if ($request->has('visibility')) {
            $query->where('is_public', $request->visibility === 'public');
        }

        $builds = $query->latest()->paginate(50);

        return view('admin.builds.index', compact('builds'));
    }

    /**
     * Feature/unfeature a build
     */
    public function toggleBuildFeatured($id)
    {
        $build = Build::findOrFail($id);
        $build->featured = !$build->featured;
        $build->save();

        return redirect()->back()
            ->with('success', 'Build ' . ($build->featured ? 'featured' : 'unfeatured'));
    }

    /**
     * Delete build
     */
    public function deleteBuild($id)
    {
        $build = Build::findOrFail($id);
        $build->delete();

        return redirect()->back()
            ->with('success', 'Build deleted successfully');
    }

    /**
     * Users management index
     */
    public function users(Request $request)
    {
        $query = User::withCount(['builds']);

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            });
        }

        $users = $query->latest()->paginate(50);

        return view('admin.users.index', compact('users'));
    }

    /**
     * Comments management index
     */
    public function comments(Request $request)
    {
        $query = BuildComment::with(['user', 'build']);

        $comments = $query->latest()->paginate(50);

        return view('admin.comments.index', compact('comments'));
    }

    /**
     * Delete comment
     */
    public function deleteComment($id)
    {
        $comment = BuildComment::findOrFail($id);
        $comment->delete();

        return redirect()->back()
            ->with('success', 'Comment deleted successfully');
    }

    /**
     * Bulk import components page
     */
    public function importComponents()
    {
        return view('admin.import.components');
    }

    /**
     * Process bulk import
     */
    public function processImport(Request $request)
    {
        $request->validate([
            'import_file' => 'required|file|mimes:csv,json|max:10240', // 10MB max
        ]);

        try {
            $file = $request->file('import_file');
            $extension = $file->getClientOriginalExtension();

            $imported = 0;
            $errors = [];

            if ($extension === 'json') {
                $json = json_decode(file_get_contents($file->path()), true);

                foreach ($json as $item) {
                    try {
                        Component::create($item);
                        $imported++;
                    } catch (\Exception $e) {
                        $errors[] = "Failed to import: " . ($item['name'] ?? 'Unknown');
                    }
                }
            } elseif ($extension === 'csv') {
                // CSV import logic
                $handle = fopen($file->path(), 'r');
                $header = fgetcsv($handle);

                while (($row = fgetcsv($handle)) !== false) {
                    try {
                        $data = array_combine($header, $row);
                        Component::create($data);
                        $imported++;
                    } catch (\Exception $e) {
                        $errors[] = "Failed to import row";
                    }
                }
                fclose($handle);
            }

            $message = "Imported {$imported} components";
            if (count($errors) > 0) {
                $message .= ". " . count($errors) . " errors.";
            }

            return redirect()->route('admin.components')
                ->with('success', $message);

        } catch (\Exception $e) {
            return redirect()->back()
                ->with('error', 'Import failed: ' . $e->getMessage());
        }
    }
}
