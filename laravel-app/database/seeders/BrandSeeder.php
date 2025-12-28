<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use App\Models\Brand;

class BrandSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $this->command->info("📦 Importing Brands...");
        
        $csvFiles = [
            'cpu.csv',
            'motherboard.csv',
            'ram.csv',
            'gpu.csv',
            'ssd.csv',
            'psu.csv',
            'case.csv',
            'cooler.csv',
        ];

        $brands = [];
        
        foreach ($csvFiles as $csvFile) {
            $path = base_path("data/csv_cleaned/{$csvFile}");
            
            if (!file_exists($path)) {
                continue;
            }
            
            $handle = fopen($path, 'r');
            $headers = fgetcsv($handle);
            
            // Find brand column index
            $brandIndex = array_search('brand', $headers);
            
            if ($brandIndex === false) {
                fclose($handle);
                continue;
            }
            
            while (($row = fgetcsv($handle)) !== false) {
                if (isset($row[$brandIndex]) && !empty($row[$brandIndex])) {
                    $brandName = trim($row[$brandIndex]);
                    if ($brandName !== '' && $brandName !== 'Unknown') {
                        $brands[$brandName] = [
                            'brand_name' => $brandName,
                            'brand_slug' => Str::slug($brandName),
                            'is_active' => true,
                            'created_at' => now(),
                            'updated_at' => now()
                        ];
                    }
                }
            }
            
            fclose($handle);
        }
        
        // Insert brands
        if (!empty($brands)) {
            try {
                DB::table('brands')->upsert(
                    array_values($brands),
                    ['brand_slug'],
                    ['brand_name', 'is_active', 'updated_at']
                );
                
                $count = count($brands);
                $this->command->info("✅ {$count} unique brands imported");
            } catch (\Exception $e) {
                $this->command->error("❌ Error importing brands: {$e->getMessage()}");
            }
        } else {
            $this->command->warn("⚠️  No brands found");
        }
    }
}
