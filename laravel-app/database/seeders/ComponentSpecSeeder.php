<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use App\Models\Component;

class ComponentSpecSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * Populates component_specs table from CSV data
     */
    public function run(): void
    {
        $this->command->info("📊 Starting component specs import...\n");

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

        // Fields that are component properties, not specs
        $commonFields = ['brand', 'name', 'price_usd', 'price_bdt', 'price', 'image_url'];

        $stats = [];

        foreach ($categories as $key => $config) {
            $csvFile = base_path("data/csv_cleaned/{$config['csv']}");

            if (!file_exists($csvFile)) {
                $this->command->warn("⚠️  Skipping {$key}: File not found");
                continue;
            }

            $this->command->info("📦 Processing {$key} specs...");

            $handle = fopen($csvFile, 'r');
            $headers = fgetcsv($handle);

            $specsInserted = 0;
            $skipped = 0;
            $batchSize = 1000;
            $specsBatch = [];

            while (($row = fgetcsv($handle)) !== false) {
                try {
                    if (empty($row) || !isset($row[0]) || empty($row[0])) {
                        continue;
                    }

                    $data = array_combine($headers, $row);

                    // Find the component by name
                    $component = Component::where('name', $data['name'])
                        ->where('category', $config['category'])
                        ->first();

                    if (!$component) {
                        $skipped++;
                        continue;
                    }

                    // Extract specs (all non-common fields)
                    foreach ($data as $header => $value) {
                        if (!in_array($header, $commonFields) && !empty($value) && $value !== '') {
                            $specsBatch[] = [
                                'component_id' => $component->id, // Now we have the actual numeric ID
                                'spec_key' => $header,
                                'spec_value' => $value,
                                'spec_unit' => null,
                                'created_at' => now(),
                                'updated_at' => now(),
                            ];
                        }
                    }

                    // Insert in batches
                    if (count($specsBatch) >= $batchSize) {
                        try {
                            DB::table('component_specs')->insert($specsBatch);
                            $specsInserted += count($specsBatch);
                            $specsBatch = [];

                            if ($specsInserted % 5000 == 0) {
                                $this->command->line("  ... {$specsInserted} specs inserted");
                            }
                        } catch (\Exception $e) {
                            $this->command->error("  ❌ Batch insert error: {$e->getMessage()}");
                            $specsBatch = [];
                        }
                    }

                } catch (\Exception $e) {
                    // Silent skip for individual errors
                }
            }

            // Insert remaining specs
            if (!empty($specsBatch)) {
                try {
                    DB::table('component_specs')->insert($specsBatch);
                    $specsInserted += count($specsBatch);
                } catch (\Exception $e) {
                    $this->command->error("  ❌ Final batch error: {$e->getMessage()}");
                }
            }

            fclose($handle);

            $stats[$key] = [
                'specs' => $specsInserted,
                'skipped' => $skipped
            ];

            $this->command->info("  ✅ {$key}: {$specsInserted} specs inserted, {$skipped} components not found\n");
        }

        $this->command->newLine();
        $this->command->info('=== Spec Import Summary ===');

        foreach ($stats as $category => $stat) {
            $this->command->line(sprintf("%-30s: %5d specs inserted",
                $category, $stat['specs']));
        }

        $totalSpecs = array_sum(array_column($stats, 'specs'));
        $this->command->newLine();
        $this->command->info("Total specs imported: {$totalSpecs}");
        $this->command->info("✨ Component specs import complete!\n");
    }
}
