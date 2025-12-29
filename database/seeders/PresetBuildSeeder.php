<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Build;
use App\Models\Component;
use App\Models\User;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;

class PresetBuildSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Check if we have components
        $componentCount = DB::table('components')->count();
        
        if ($componentCount === 0) {
            $this->command->warn('⚠️  No components found in database. Skipping preset builds.');
            return;
        }

        // Get admin user
        $admin = User::where('email', 'admin@rigcheck.com')->first();
        if (!$admin) {
            $this->command->error('⚠️  Admin user not found. Run AdminUserSeeder first.');
            return;
        }

        $this->command->info("📦 Found {$componentCount} components in database");
        $this->command->info("👤 Creating builds as: {$admin->name} ({$admin->email})\n");

        $presetBuilds = [
            // 1. Ultimate Gaming Build
            [
                'build_name' => '🎮 Ultimate Gaming Rig 2025',
                'description' => 'Top-tier gaming build with latest RTX 40-series GPU and high-end CPU for 4K gaming at ultra settings. Perfect for AAA titles and competitive gaming.',
                'use_case' => 'gaming',
                'budget_min_bdt' => 400000,
                'budget_max_bdt' => 600000,
                'visibility' => 'public',
                'is_complete' => true,
                'categories' => ['cpu', 'motherboard', 'gpu', 'ram', 'storage', 'psu', 'case', 'cooler'],
            ],
            // 2. High-End Content Creation
            [
                'build_name' => '🎥 Content Creator Studio',
                'description' => 'Professional workstation optimized for video editing, 3D rendering, and content creation. High core count CPU with ample RAM for multitasking.',
                'use_case' => 'content_creation',
                'budget_min_bdt' => 300000,
                'budget_max_bdt' => 500000,
                'visibility' => 'public',
                'is_complete' => true,
                'categories' => ['cpu', 'motherboard', 'gpu', 'ram', 'storage', 'psu', 'case', 'cooler'],
            ],
            // 3. Professional Workstation
            [
                'build_name' => '💼 Engineering Workstation Pro',
                'description' => 'High-performance workstation for CAD, engineering simulations, and professional applications. Rock-solid stability with ECC support.',
                'use_case' => 'workstation',
                'budget_min_bdt' => 250000,
                'budget_max_bdt' => 400000,
                'visibility' => 'public',
                'is_complete' => true,
                'categories' => ['cpu', 'motherboard', 'ram', 'storage', 'psu', 'case', 'cooler'],
            ],
            // 4. Budget Gaming Build
            [
                'build_name' => '💰 Budget Gaming Champion',
                'description' => 'Affordable 1080p gaming build that delivers excellent performance without breaking the bank. Perfect for esports and modern titles at high settings.',
                'use_case' => 'budget',
                'budget_min_bdt' => 80000,
                'budget_max_bdt' => 150000,
                'visibility' => 'public',
                'is_complete' => true,
                'categories' => ['cpu', 'motherboard', 'gpu', 'ram', 'storage', 'psu', 'case'],
            ],
            // 5. Office Productivity
            [
                'build_name' => '🖥️ Office Productivity Hub',
                'description' => 'Reliable and efficient build for office work, web browsing, and productivity software. Energy-efficient with integrated graphics.',
                'use_case' => 'other',
                'budget_min_bdt' => 40000,
                'budget_max_bdt' => 80000,
                'visibility' => 'public',
                'is_complete' => true,
                'categories' => ['cpu', 'motherboard', 'ram', 'storage', 'psu', 'case'],
            ],
            // 6. Streaming Build
            [
                'build_name' => '🎬 Streamer Special',
                'description' => 'Balanced build for gaming and live streaming with excellent multi-threaded performance. Stream in 1080p60fps while gaming smoothly.',
                'use_case' => 'gaming',
                'budget_min_bdt' => 200000,
                'budget_max_bdt' => 350000,
                'visibility' => 'public',
                'is_complete' => true,
                'categories' => ['cpu', 'motherboard', 'gpu', 'ram', 'storage', 'psu', 'case', 'cooler'],
            ],
            // 7. Mid-Range All-Rounder
            [
                'build_name' => '⚡ Mid-Range Master',
                'description' => 'Versatile mid-range build perfect for 1440p gaming, light content creation, and everyday tasks. Best value for money.',
                'use_case' => 'gaming',
                'budget_min_bdt' => 150000,
                'budget_max_bdt' => 250000,
                'visibility' => 'public',
                'is_complete' => true,
                'categories' => ['cpu', 'motherboard', 'gpu', 'ram', 'storage', 'psu', 'case', 'cooler'],
            ],
            // 8. Compact Mini-ITX Build
            [
                'build_name' => '📦 Compact Gaming Beast',
                'description' => 'Small form factor build that packs serious gaming power in a tiny package. Perfect for limited desk space or LAN parties.',
                'use_case' => 'gaming',
                'budget_min_bdt' => 180000,
                'budget_max_bdt' => 300000,
                'visibility' => 'public',
                'is_complete' => true,
                'categories' => ['cpu', 'motherboard', 'gpu', 'ram', 'storage', 'psu', 'case', 'cooler'],
            ],
            // 9. RGB Gaming Showcase
            [
                'build_name' => '🌈 RGB Dream Machine',
                'description' => 'Eye-catching gaming build with synchronized RGB lighting and tempered glass showcase. Performance meets aesthetics.',
                'use_case' => 'gaming',
                'budget_min_bdt' => 220000,
                'budget_max_bdt' => 380000,
                'visibility' => 'public',
                'is_complete' => true,
                'categories' => ['cpu', 'motherboard', 'gpu', 'ram', 'storage', 'psu', 'case', 'cooler'],
            ],
            // 10. Silent Workstation
            [
                'build_name' => '🔇 Silent Productivity Beast',
                'description' => 'Whisper-quiet build optimized for noise-sensitive environments. Perfect for home office or content recording with minimal fan noise.',
                'use_case' => 'workstation',
                'budget_min_bdt' => 160000,
                'budget_max_bdt' => 280000,
                'visibility' => 'public',
                'is_complete' => true,
                'categories' => ['cpu', 'motherboard', 'ram', 'storage', 'psu', 'case', 'cooler'],
            ],
        ];

        foreach ($presetBuilds as $buildData) {
            $categories = $buildData['categories'];
            unset($buildData['categories']);

            // Create build as admin user
            $build = Build::create([
                ...$buildData,
                'user_id' => $admin->id,  // Assign to admin user
                'share_token' => Str::random(16),
                'share_id' => Str::random(10),
                'total_cost_bdt' => 0, // Will be calculated
                'compatibility_status' => 'valid',
                'view_count' => rand(50, 500),  // Add some realistic view counts
                'like_count' => rand(5, 50),    // Add some likes
                'comment_count' => 0,
            ]);

            // Get components by category for this build
            $totalCost = 0;
            $componentsAttached = 0;

            foreach ($categories as $category) {
                // Get a random component for this category within budget
                $component = DB::table('components')
                    ->where('category', $category)
                    ->whereNotNull('lowest_price_bdt')
                    ->where('lowest_price_bdt', '>', 0)
                    ->inRandomOrder()
                    ->first();
                
                if ($component) {
                    $price = $component->lowest_price_bdt ?? 0;
                    $quantity = 1;
                    
                    // Special quantities for certain categories
                    if ($category === 'ram') {
                        $quantity = 2; // 2 sticks of RAM
                    } elseif ($category === 'storage' && rand(0, 1)) {
                        $quantity = 2; // Sometimes 2 storage drives
                    }
                    
                    $totalCost += ($price * $quantity);

                    // Attach to build
                    DB::table('build_components')->insert([
                        'build_id' => $build->id,
                        'component_id' => $component->id,
                        'category' => $category,
                        'quantity' => $quantity,
                        'price_at_selection_bdt' => $price,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                    
                    $componentsAttached++;
                }
            }

            // Update total cost
            $build->update(['total_cost_bdt' => $totalCost]);

            $this->command->info("✅ Created: {$build->build_name} (৳" . number_format($totalCost) . ", {$componentsAttached} components)");
        }

        $this->command->info("\n✨ Successfully created " . count($presetBuilds) . " preset builds as admin user!\n");
    }
}
