<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Build;
use App\Models\Component;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;

class PresetBuildSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get some sample components (use existing or create dummy data)
        $components = DB::table('components')->limit(50)->get();

        if ($components->isEmpty()) {
            $this->command->warn('⚠️  No components found in database. Skipping preset builds.');
            return;
        }

        $presetBuilds = [
            // Gaming Build - High Performance
            [
                'build_name' => '🎮 Gaming Beast',
                'description' => 'High-performance gaming build with RTX GPU and powerful CPU for 4K gaming',
                'use_case' => 'gaming',
                'budget_min_bdt' => 300000,
                'budget_max_bdt' => 500000,
                'visibility' => 'public',
                'is_complete' => true,
                'categories' => ['cpu', 'motherboard', 'gpu', 'ram', 'storage', 'psu', 'case', 'cooler'],
            ],
            // Content Creation Build
            [
                'build_name' => '🎥 Creator Pro',
                'description' => 'Optimized for video editing, 3D rendering, and content creation with high core count CPU',
                'use_case' => 'content_creation',
                'budget_min_bdt' => 250000,
                'budget_max_bdt' => 400000,
                'visibility' => 'public',
                'is_complete' => true,
                'categories' => ['cpu', 'motherboard', 'ram', 'storage', 'psu', 'case', 'cooler'],
            ],
            // Workstation Build
            [
                'build_name' => '💼 Workstation Pro',
                'description' => 'Professional workstation for engineering, CAD, and heavy computational tasks',
                'use_case' => 'workstation',
                'budget_min_bdt' => 200000,
                'budget_max_bdt' => 350000,
                'visibility' => 'public',
                'is_complete' => true,
                'categories' => ['cpu', 'motherboard', 'ram', 'storage', 'psu', 'case', 'cooler'],
            ],
            // Budget Gaming Build
            [
                'build_name' => '💰 Budget Gamer',
                'description' => 'Affordable gaming build for 1080p gaming at high settings',
                'use_case' => 'budget',
                'budget_min_bdt' => 80000,
                'budget_max_bdt' => 150000,
                'visibility' => 'public',
                'is_complete' => true,
                'categories' => ['cpu', 'motherboard', 'gpu', 'ram', 'storage', 'psu', 'case'],
            ],
            // Office/Productivity Build
            [
                'build_name' => '🖥️ Office Workhorse',
                'description' => 'Reliable build for office work, web browsing, and productivity tasks',
                'use_case' => 'other',
                'budget_min_bdt' => 40000,
                'budget_max_bdt' => 80000,
                'visibility' => 'public',
                'is_complete' => true,
                'categories' => ['cpu', 'motherboard', 'ram', 'storage', 'psu', 'case'],
            ],
            // Streaming Build
            [
                'build_name' => '🎬 Streamer Setup',
                'description' => 'Balanced build for gaming and live streaming with excellent CPU',
                'use_case' => 'gaming',
                'budget_min_bdt' => 200000,
                'budget_max_bdt' => 350000,
                'visibility' => 'public',
                'is_complete' => true,
                'categories' => ['cpu', 'motherboard', 'gpu', 'ram', 'storage', 'psu', 'case', 'cooler'],
            ],
        ];

        foreach ($presetBuilds as $buildData) {
            $categories = $buildData['categories'];
            unset($buildData['categories']);

            // Create build
            $build = Build::create([
                ...$buildData,
                'share_token' => Str::random(16),
                'share_url' => 'https://rigcheck.com/builds/' . Str::random(8),
                'total_cost_bdt' => 0, // Will be calculated
                'compatibility_status' => 'valid',
                'view_count' => 0,
                'like_count' => 0,
                'comment_count' => 0,
            ]);

            // Attach random components for each category
            $componentsByCategory = $components->groupBy('category');
            $totalCost = 0;

            foreach ($categories as $category) {
                $available = $componentsByCategory->get($category);
                if ($available && $available->isNotEmpty()) {
                    $component = $available->random();
                    $price = $component->lowest_price_bdt ?? 0;
                    $totalCost += $price;

                    $build->components()->attach($component->id, [
                        'category' => $category,
                        'quantity' => 1,
                        'price_at_selection_bdt' => $price,
                    ]);
                }
            }

            // Update total cost
            $build->update(['total_cost_bdt' => $totalCost]);

            $this->command->info("✅ Created: {$build->build_name} (৳{$totalCost})");
        }

        $this->command->info("\n✨ All preset builds created successfully!\n");
    }
}
