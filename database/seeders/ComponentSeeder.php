<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Component;
use App\Models\Brand;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;

class ComponentSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = [
            'cpu' => ['csv' => 'cpu.csv', 'category' => 'cpu'],
            'motherboard' => ['csv' => 'motherboard.csv', 'category' => 'motherboard'],
            'memory' => ['csv' => 'memory.csv', 'category' => 'ram'],
            'video-card' => ['csv' => 'video-card.csv', 'category' => 'gpu'],
            'internal-hard-drive' => ['csv' => 'internal-hard-drive.csv', 'category' => 'storage'],
            'power-supply' => ['csv' => 'power-supply.csv', 'category' => 'psu'],
            'case' => ['csv' => 'case.csv', 'category' => 'case'],
            'cpu-cooler' => ['csv' => 'cpu-cooler.csv', 'category' => 'cooler'],
        ];

        $stats = [];
        
        // Track product_ids seen within current run to avoid intra-batch duplicates
        $seenProductIdsGlobal = [];

        foreach ($categories as $key => $config) {
            $csvFile = base_path("data/csv/{$config['csv']}");
            
            if (!file_exists($csvFile)) {
                $this->command->warn("⚠️  Skipping {$key}: File not found at {$csvFile}");
                continue;
            }
            
            $this->command->info("📦 Importing {$key}...");
            
            $handle = fopen($csvFile, 'r');
            $headers = fgetcsv($handle);
            
            $imported = 0;
            $skipped = 0;
            $errors = 0;
            $batchSize = 500;
            $batch = [];
            $seenProductIds = [];
            
            while (($row = fgetcsv($handle)) !== false) {
                try {
                    if (empty($row) || !isset($row[0]) || empty($row[0])) {
                        continue;
                    }
                    
                    $data = array_combine($headers, $row);
                    
                    // Extract brand from product name (first word)
                    $nameParts = explode(' ', $data['name']);
                    $brandName = $nameParts[0];
                    
                    // Get or create brand
                    $brand = Brand::firstOrCreate(
                        ['brand_name' => $brandName],
                        [
                            'brand_slug' => Str::slug($brandName),
                            'is_active' => true,
                            'created_at' => now()
                        ]
                    );
                    
                    // Generate unique product_id
                    $productId = Str::slug($data['name']);
                    
                    // Check if already exists in DB or already queued in this batch/run
                    if (isset($seenProductIdsGlobal[$productId]) || isset($seenProductIds[$productId]) || Component::where('product_id', $productId)->exists()) {
                        $skipped++;
                        continue;
                    }
                    
                    // Parse price
                    $price = 0;
                    if (isset($data['price']) && !empty($data['price'])) {
                        $price = (float)str_replace(',', '', $data['price']);
                    }
                    
                    // Create component record
                    $record = [
                        'product_id' => $productId,
                        'sku' => $productId,
                        'category' => $config['category'],
                        'name' => $data['name'],
                        'brand_id' => $brand->id,
                        'series' => null,
                        'model' => $productId,
                        'primary_image_url' => null,
                        'image_urls' => json_encode([]),
                        'lowest_price_usd' => $price > 0 ? $price : null,
                        'lowest_price_bdt' => $price > 0 ? $price * 120 : null,
                        'price_last_updated' => now(),
                        'availability_status' => 'in_stock',
                        'stock_count' => rand(0, 100),
                        'featured' => false,
                        'slug' => $productId,
                        'data_version' => 1,
                        'view_count' => 0,
                        'build_count' => 0,
                        'popularity_score' => 0,
                        'is_verified' => false,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ];
                    
                    // Track seen to avoid duplicate enqueue in batch and across categories
                    $seenProductIds[$productId] = true;
                    $seenProductIdsGlobal[$productId] = true;
                    $batch[] = $record;
                    
                    // Insert in batches
                    if (count($batch) >= $batchSize) {
                        // Use upsert to avoid unique constraint failures (product_id, slug)
                        try {
                            DB::table('components')->upsert(
                                $batch,
                                ['product_id'],
                                [
                                    'sku','category','name','brand_id','series','model','primary_image_url','image_urls',
                                    'lowest_price_usd','lowest_price_bdt','price_last_updated','availability_status','stock_count',
                                    'featured','slug','data_version','view_count','build_count','popularity_score','is_verified','updated_at'
                                ]
                            );
                            $imported += count($batch);
                            $batch = [];
                            if ($imported % 1000 == 0) {
                                $this->command->line("  ... {$imported} components imported");
                            }
                        } catch (\Exception $e) {
                            $errors++;
                            $this->command->error("  ❌ Batch upsert error: {$e->getMessage()}");
                            // On error, clear batch to progress and avoid repeated failures
                            $batch = [];
                        }
                    }
                    
                } catch (\Exception $e) {
                    $errors++;
                    if ($errors <= 3) {
                        $this->command->error("  ❌ Error: {$e->getMessage()}");
                    }
                }
            }
            
            // Insert remaining batch
            if (!empty($batch)) {
                try {
                    DB::table('components')->upsert(
                        $batch,
                        ['product_id'],
                        [
                            'sku','category','name','brand_id','series','model','primary_image_url','image_urls',
                            'lowest_price_usd','lowest_price_bdt','price_last_updated','availability_status','stock_count',
                            'featured','slug','data_version','view_count','build_count','popularity_score','is_verified','updated_at'
                        ]
                    );
                    $imported += count($batch);
                } catch (\Exception $e) {
                    $errors++;
                    $this->command->error("  ❌ Final batch upsert error: {$e->getMessage()}");
                }
            }
            
            fclose($handle);
            
            $stats[$key] = [
                'imported' => $imported,
                'skipped' => $skipped,
                'errors' => $errors
            ];
            
            $this->command->info("  ✅ {$key}: {$imported} imported, {$skipped} skipped, {$errors} errors\n");
        }

        $this->command->newLine();
        $this->command->info('=== Import Summary ===');
        
        foreach ($stats as $category => $stat) {
            $this->command->line(sprintf("%-30s: %4d imported, %4d skipped, %4d errors", 
                $category, $stat['imported'], $stat['skipped'], $stat['errors']));
        }
        
        $total = array_sum(array_column($stats, 'imported'));
        $this->command->newLine();
        $this->command->info("Total components imported: {$total}");
    }
}
