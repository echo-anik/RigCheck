<?php
/**
 * Import all component categories from CSV files
 * Run: docker-compose exec app php import_all_components.php
 */

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Component;
use App\Models\Brand;
use Illuminate\Support\Str;

$categories = [
    'cpu',
    'motherboard',
    'memory',
    'video-card',
    'internal-hard-drive',
    'power-supply',
    'case',
    'cpu-cooler',
    'case-fan',
    'monitor',
    'keyboard',
    'mouse',
    'headphones',
    'speakers',
    'webcam',
    'os',
    'optical-drive',
    'sound-card',
    'wired-network-card',
    'wireless-network-card',
    'thermal-paste',
    'external-hard-drive',
    'ups',
    'fan-controller',
    'case-accessory'
];

$stats = [];

foreach ($categories as $category) {
    $csvFile = __DIR__."/data/csv/{$category}.csv";
    
    if (!file_exists($csvFile)) {
        echo "⚠️  Skipping {$category}: File not found\n";
        continue;
    }
    
    echo "📦 Importing {$category}...\n";
    
    $handle = fopen($csvFile, 'r');
    $headers = fgetcsv($handle);
    
    $imported = 0;
    $skipped = 0;
    $errors = 0;
    
    while (($row = fgetcsv($handle)) !== false) {
        try {
            $data = array_combine($headers, $row);
            
            // Extract brand
            $brandName = $data['manufacturer'] ?? $data['brand'] ?? 'Unknown';
            $brand = Brand::firstOrCreate(
                ['brand_name' => $brandName],
                ['brand_slug' => Str::slug($brandName)]
            );
            
            // Check if component already exists
            $productId = $data['part-number'] ?? $data['model'] ?? Str::slug($data['name']);
            if (Component::where('product_id', $productId)->exists()) {
                $skipped++;
                continue;
            }
            
            // Parse price
            $price = 0;
            if (isset($data['price'])) {
                $price = (float)preg_replace('/[^0-9.]/', '', $data['price']);
            }
            
            // Create component
            Component::create([
                'product_id' => $productId,
                'sku' => $data['part-number'] ?? $productId,
                'category' => str_replace('-', '_', $category),
                'name' => $data['name'],
                'brand_id' => $brand->id,
                'series' => $data['series'] ?? null,
                'model' => $data['model'] ?? $data['part-number'] ?? null,
                'primary_image_url' => null,
                'image_urls' => json_encode([]),
                'lowest_price_usd' => $price > 0 ? $price : null,
                'lowest_price_bdt' => $price > 0 ? $price * 120 : null,
                'price_last_updated' => now(),
                'availability_status' => 'in_stock',
                'stock_count' => rand(1, 50),
                'featured' => false,
                'slug' => Str::slug($data['name']),
                'data_version' => 1
            ]);
            
            $imported++;
            
            if ($imported % 100 == 0) {
                echo "  ... {$imported} components imported\n";
            }
        } catch (\Exception $e) {
            $errors++;
            if ($errors < 5) {
                echo "  ❌ Error: {$e->getMessage()}\n";
            }
        }
    }
    
    fclose($handle);
    
    $stats[$category] = [
        'imported' => $imported,
        'skipped' => $skipped,
        'errors' => $errors
    ];
    
    echo "  ✅ {$category}: {$imported} imported, {$skipped} skipped, {$errors} errors\n\n";
}

echo "\n=== Import Summary ===\n";
foreach ($stats as $category => $stat) {
    echo sprintf("%-30s: %4d imported, %4d skipped, %4d errors\n", 
        $category, $stat['imported'], $stat['skipped'], $stat['errors']);
}

$total = array_sum(array_column($stats, 'imported'));
echo "\nTotal components imported: {$total}\n";
