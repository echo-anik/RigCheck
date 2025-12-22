<?php

require __DIR__ . '/vendor/autoload.php';

use Illuminate\Database\Capsule\Manager as DB;

// Bootstrap Laravel database connection
$capsule = new DB;
$capsule->addConnection([
    'driver' => 'mysql',
    'host' => getenv('DB_HOST') ?: 'localhost',
    'port' => getenv('DB_PORT') ?: '3308',
    'database' => getenv('DB_DATABASE') ?: 'pc_builder',
    'username' => getenv('DB_USERNAME') ?: 'root',
    'password' => getenv('DB_PASSWORD') ?: 'root',
    'charset' => 'utf8mb4',
    'collation' => 'utf8mb4_unicode_ci',
    'prefix' => '',
]);
$capsule->setAsGlobal();
$capsule->bootEloquent();

echo "🚀 Starting import from cleaned CSV files...\n\n";

// Clear existing components and prices (in correct order due to foreign keys)
echo "🗑️  Clearing existing data...\n";
DB::statement('SET FOREIGN_KEY_CHECKS=0;');
DB::table('prices')->truncate();
DB::table('components')->truncate();
DB::statement('SET FOREIGN_KEY_CHECKS=1;');
echo "✅ Data cleared!\n\n";

$csvPath = '/var/www/data/csv_cleaned/';
echo "📁 Looking for CSV files in: {$csvPath}\n\n";
$totalImported = 0;
$totalErrors = 0;

// Category mapping
$categoryMap = [
    'cpu' => 'cpu',
    'motherboard' => 'motherboard',
    'gpu' => 'gpu',
    'ram' => 'ram',
    'ssd' => 'storage',
    'psu' => 'psu',
    'case' => 'case',
    'cooler' => 'cooler'
];

// Function to generate a short unique ID
function generateId($category, $index) {
    return strtoupper(substr($category, 0, 3)) . str_pad($index, 6, '0', STR_PAD_LEFT);
}

// Function to clean numeric values
function cleanNumeric($value) {
    if (empty($value)) return null;
    return is_numeric($value) ? (float)$value : null;
}

// Function to clean boolean values
function cleanBoolean($value) {
    if (empty($value)) return false;
    return in_array(strtolower($value), ['true', '1', 'yes']) ? true : false;
}

foreach ($categoryMap as $filename => $category) {
    $filepath = $csvPath . $filename . '.csv';
    
    if (!file_exists($filepath)) {
        echo "⚠️  File not found: {$filename}.csv\n";
        continue;
    }
    
    echo "📦 Importing {$filename}.csv...\n";
    
    $file = fopen($filepath, 'r');
    $headers = fgetcsv($file);
    
    $count = 0;
    $errors = 0;
    $index = 1;
    
    while (($row = fgetcsv($file)) !== false) {
        try {
            $data = array_combine($headers, $row);
            
            // Skip if no name
            if (empty($data['name'])) {
                continue;
            }
            
            $componentId = generateId($category, $index);
            
            // Common fields
            $brand = $data['brand'] ?? '';
            $model = $data['name'] ?? '';
            $priceUsd = cleanNumeric($data['price_usd'] ?? 0);
            $priceBdt = cleanNumeric($data['price_bdt'] ?? 0);
            $imageUrl = $data['image_url'] ?? '';
            
            // Build specs JSON based on category
            $specs = [];
            
            switch ($category) {
                case 'cpu':
                    $specs = [
                        'socket' => $data['socket'] ?? '',
                        'core_count' => cleanNumeric($data['core_count']),
                        'core_clock' => cleanNumeric($data['core_clock']),
                        'boost_clock' => cleanNumeric($data['boost_clock']),
                        'microarchitecture' => $data['microarchitecture'] ?? '',
                        'tdp' => cleanNumeric($data['tdp']),
                        'graphics' => $data['graphics'] ?? '',
                        'has_integrated_graphics' => cleanBoolean($data['has_integrated_graphics'] ?? 'false'),
                        'price_usd' => $priceUsd,
                        'image_url' => $imageUrl
                    ];
                    break;
                    
                case 'motherboard':
                    $specs = [
                        'socket' => $data['socket'] ?? '',
                        'chipset' => $data['chipset'] ?? '',
                        'form_factor' => $data['form_factor'] ?? '',
                        'max_memory_gb' => cleanNumeric($data['max_memory_gb']),
                        'memory_slots' => cleanNumeric($data['memory_slots']),
                        'memory_type' => $data['memory_type'] ?? '',
                        'm2_slots' => cleanNumeric($data['m2_slots']),
                        'color' => $data['color'] ?? '',
                        'price_usd' => $priceUsd,
                        'image_url' => $imageUrl
                    ];
                    break;
                    
                case 'gpu':
                    $specs = [
                        'chipset' => $data['chipset'] ?? '',
                        'memory_gb' => cleanNumeric($data['memory_gb']),
                        'memory_type' => $data['memory_type'] ?? '',
                        'core_clock' => cleanNumeric($data['core_clock']),
                        'boost_clock' => cleanNumeric($data['boost_clock']),
                        'color' => $data['color'] ?? '',
                        'length_mm' => cleanNumeric($data['length_mm']),
                        'tdp' => cleanNumeric($data['tdp']),
                        'price_usd' => $priceUsd,
                        'image_url' => $imageUrl
                    ];
                    break;
                    
                case 'ram':
                    $specs = [
                        'capacity_gb' => cleanNumeric($data['capacity_gb']),
                        'ddr_generation' => $data['ddr_generation'] ?? '',
                        'speed_mhz' => cleanNumeric($data['speed_mhz']),
                        'modules' => $data['modules'] ?? '',
                        'cas_latency' => cleanNumeric($data['cas_latency']),
                        'color' => $data['color'] ?? '',
                        'price_per_gb' => cleanNumeric($data['price_per_gb']),
                        'price_usd' => $priceUsd,
                        'image_url' => $imageUrl
                    ];
                    break;
                    
                case 'storage':
                    $specs = [
                        'capacity_gb' => cleanNumeric($data['capacity_gb']),
                        'form_factor' => $data['form_factor'] ?? '',
                        'interface' => $data['interface'] ?? '',
                        'cache_mb' => cleanNumeric($data['cache_mb']),
                        'price_per_gb' => cleanNumeric($data['price_per_gb']),
                        'price_usd' => $priceUsd,
                        'image_url' => $imageUrl
                    ];
                    break;
                    
                case 'psu':
                    $specs = [
                        'wattage' => cleanNumeric($data['wattage']),
                        'efficiency_rating' => $data['efficiency_rating'] ?? '',
                        'modular' => $data['modular'] ?? '',
                        'form_factor' => $data['form_factor'] ?? '',
                        'color' => $data['color'] ?? '',
                        'price_usd' => $priceUsd,
                        'image_url' => $imageUrl
                    ];
                    break;
                    
                case 'case':
                    $specs = [
                        'form_factor' => $data['form_factor'] ?? '',
                        'color' => $data['color'] ?? '',
                        'side_panel' => $data['side_panel'] ?? '',
                        'external_volume' => cleanNumeric($data['external_volume']),
                        'internal_35_bays' => cleanNumeric($data['internal_35_bays']),
                        'price_usd' => $priceUsd,
                        'image_url' => $imageUrl
                    ];
                    break;
                    
                case 'cooler':
                    $specs = [
                        'fan_rpm' => $data['fan_rpm'] ?? '',
                        'noise_level' => $data['noise_level'] ?? '',
                        'color' => $data['color'] ?? '',
                        'radiator_size' => $data['radiator_size'] ?? '',
                        'height_mm' => cleanNumeric($data['height_mm']),
                        'price_usd' => $priceUsd,
                        'image_url' => $imageUrl
                    ];
                    break;
            }
            
            // Insert component
            DB::table('components')->insert([
                'id' => $componentId,
                'category' => $category,
                'brand' => $brand,
                'model' => $model,
                'specs' => json_encode($specs),
                'raw_name' => $model,
                'created_at' => now(),
                'updated_at' => now()
            ]);
            
            // Insert price if available
            if ($priceBdt > 0) {
                DB::table('prices')->insert([
                    'component_id' => $componentId,
                    'source' => 'pcpartpicker',
                    'price_bdt' => $priceBdt,
                    'url' => '',
                    'availability' => 'in_stock',
                    'last_updated' => now()
                ]);
            }
            
            $count++;
            $index++;
            
        } catch (Exception $e) {
            $errors++;
            echo "   ❌ Error: {$e->getMessage()}\n";
        }
    }
    
    fclose($file);
    
    echo "   ✅ Imported {$count} {$category}s";
    if ($errors > 0) {
        echo " ({$errors} errors)";
    }
    echo "\n";
    
    $totalImported += $count;
    $totalErrors += $errors;
}

echo "\n";
echo "═══════════════════════════════════════════════\n";
echo "✨ Import Complete!\n";
echo "═══════════════════════════════════════════════\n";
echo "📊 Total imported: {$totalImported} components\n";
if ($totalErrors > 0) {
    echo "⚠️  Total errors: {$totalErrors}\n";
}

// Show summary
echo "\n📈 Summary by category:\n";
foreach ($categoryMap as $filename => $category) {
    $count = DB::table('components')->where('category', $category)->count();
    echo "   {$category}: {$count}\n";
}

echo "\n🎉 Done!\n";
