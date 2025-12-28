<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use App\Models\Brand;
use App\Models\Component;

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
            'ram' => ['csv' => 'ram.csv', 'category' => 'ram'],
            'gpu' => ['csv' => 'gpu.csv', 'category' => 'gpu'],
            'ssd' => ['csv' => 'ssd.csv', 'category' => 'storage'],
            'psu' => ['csv' => 'psu.csv', 'category' => 'psu'],
            'case' => ['csv' => 'case.csv', 'category' => 'case'],
            'cooler' => ['csv' => 'cooler.csv', 'category' => 'cooler'],
        ];

        $stats = [];
        $seenProductIdsGlobal = [];

        foreach ($categories as $key => $config) {
            $csvFile = base_path("data/csv_cleaned/{$config['csv']}");

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

                    // Extract brand from name (first word is usually the brand)
                    $brandName = 'Unknown';
                    if (isset($data['brand']) && !empty($data['brand'])) {
                        $brandName = $data['brand'];
                    } elseif (isset($data['name']) && !empty($data['name'])) {
                        // Extract brand from the name field (first word)
                        $nameParts = explode(' ', trim($data['name']));
                        $brandName = $nameParts[0];
                    }

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

                    // Check if already exists
                    if (isset($seenProductIdsGlobal[$productId]) || isset($seenProductIds[$productId]) || Component::where('product_id', $productId)->exists()) {
                        $skipped++;
                        continue;
                    }

                    // Parse price
                    $priceUsd = 0;
                    $priceBdt = 0;

                    if (isset($data['price_usd']) && !empty($data['price_usd'])) {
                        $priceUsd = (float)str_replace(',', '', $data['price_usd']);
                        $priceBdt = $priceUsd * 120;
                    } elseif (isset($data['price_bdt']) && !empty($data['price_bdt'])) {
                        $priceBdt = (float)str_replace(',', '', $data['price_bdt']);
                        $priceUsd = $priceBdt / 120;
                    } elseif (isset($data['price']) && !empty($data['price'])) {
                        $priceUsd = (float)str_replace(',', '', $data['price']);
                        $priceBdt = $priceUsd * 120;
                    }

                    // Create full name (especially important for GPUs)
                    $fullName = $data['name'];
                    if ($config['category'] === 'gpu' && isset($data['chipset']) && !empty($data['chipset'])) {
                        // For GPUs, combine chipset with variant name if chipset isn't already in name
                        if (stripos($data['name'], $data['chipset']) === false) {
                            $fullName = trim($brandName . ' ' . $data['chipset'] . ' ' . str_replace($brandName, '', $data['name']));
                        }
                    }

                    // Create component record
                    $record = [
                        'product_id' => $productId,
                        'sku' => $productId,
                        'category' => $config['category'],
                        'name' => $fullName,
                        'brand_id' => $brand->id,
                        'series' => isset($data['chipset']) ? $data['chipset'] : null,
                        'model' => $productId,
                        'primary_image_url' => isset($data['image_url']) ? $data['image_url'] : null,
                        'image_urls' => json_encode([]),
                        'lowest_price_usd' => $priceUsd > 0 ? $priceUsd : null,
                        'lowest_price_bdt' => $priceBdt > 0 ? $priceBdt : null,
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

                    $seenProductIds[$productId] = true;
                    $seenProductIdsGlobal[$productId] = true;
                    $batch[] = $record;

                    // Insert in batches
                    if (count($batch) >= $batchSize) {
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
        $this->command->info("\n💡 Note: Component specs will be populated by the ComponentSpecSeeder");
    }
}
