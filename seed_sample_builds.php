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

echo "🎮 Creating Sample Builds...\n\n";

// Get or create a demo user
$demoUser = DB::table('users')->where('email', 'demo@rigcheck.com')->first();
if (!$demoUser) {
    DB::table('users')->insert([
        'name' => 'Demo User',
        'email' => 'demo@rigcheck.com',
        'password' => password_hash('demo123', PASSWORD_BCRYPT),
        'role' => 'user',
        'created_at' => now(),
        'updated_at' => now()
    ]);
    $userId = DB::getPdo()->lastInsertId();
    echo "✅ Created demo user (demo@rigcheck.com / demo123)\n\n";
} else {
    $userId = $demoUser->id;
    echo "✅ Using existing demo user\n\n";
}

// Function to find component by brand and partial name
function findComponent($category, $brandPattern, $namePattern) {
    return DB::table('components')
        ->where('category', $category)
        ->where('raw_name', 'like', "%{$namePattern}%")
        ->where('brand', 'like', "%{$brandPattern}%")
        ->first();
}

// Function to find component by specs
function findComponentBySpecs($category, $specs) {
    $query = DB::table('components')->where('category', $category);
    
    foreach ($specs as $key => $value) {
        $query->whereRaw("JSON_EXTRACT(specs, '$.{$key}') = ?", [$value]);
    }
    
    return $query->first();
}

// Function to get cheapest component in category
function getCheapestInCategory($category, $limit = 1) {
    return DB::table('components')
        ->join('prices', 'components.id', '=', 'prices.component_id')
        ->where('components.category', $category)
        ->orderBy('prices.price_bdt', 'asc')
        ->select('components.*', 'prices.price_bdt')
        ->limit($limit)
        ->first();
}

// Function to get component by price range
function getComponentInPriceRange($category, $minPrice, $maxPrice) {
    return DB::table('components')
        ->join('prices', 'components.id', '=', 'prices.component_id')
        ->where('components.category', $category)
        ->whereBetween('prices.price_bdt', [$minPrice, $maxPrice])
        ->select('components.*', 'prices.price_bdt')
        ->inRandomOrder()
        ->first();
}

// Sample Build Configurations
$builds = [
    [
        'name' => 'Budget Gaming Build - Ryzen 5 5500 + RX 6600',
        'description' => 'Perfect entry-level gaming PC for 1080p gaming on medium-high settings. Great value for money with modern games running smoothly at 60+ FPS.',
        'budget_range' => 'budget',
        'components' => [
            'cpu' => ['AMD', 'Ryzen 5 5500'],
            'motherboard' => ['Asus', 'PRIME B550M'],
            'gpu' => ['', 'RX 6600'],
            'ram' => ['Corsair', 'Vengeance LPX 16'],
            'storage' => ['Crucial', 'P3 Plus', '1000'],
            'psu' => ['', '550'],
            'case' => ['Cooler Master', 'MasterBox Q300L'],
            'cooler' => ['Cooler Master', 'Hyper 212']
        ]
    ],
    [
        'name' => 'Mid-Range Powerhouse - Ryzen 7 5700X + RTX 4060 Ti',
        'description' => 'Excellent 1080p/1440p gaming build with strong multitasking performance. Handles AAA games at high settings and great for content creation.',
        'budget_range' => 'mid',
        'components' => [
            'cpu' => ['AMD', 'Ryzen 7 5700X'],
            'motherboard' => ['MSI', 'B550'],
            'gpu' => ['', 'RTX 4060 Ti'],
            'ram' => ['Corsair', 'Vengeance 32'],
            'storage' => ['Samsung', '990 Pro', '2000'],
            'psu' => ['Corsair', '650'],
            'case' => ['NZXT', 'H5 Flow'],
            'cooler' => ['Thermalright', 'Peerless Assassin']
        ]
    ],
    [
        'name' => 'High-End Gaming Beast - Ryzen 7 7800X3D + RTX 4080',
        'description' => 'Top-tier gaming PC for 1440p/4K gaming at ultra settings. Features the legendary 7800X3D for best-in-class gaming performance.',
        'budget_range' => 'high',
        'components' => [
            'cpu' => ['AMD', 'Ryzen 7 7800X3D'],
            'motherboard' => ['MSI', 'B650 GAMING PLUS'],
            'gpu' => ['', 'RTX 4080'],
            'ram' => ['G.Skill', 'Trident Z5 RGB 64'],
            'storage' => ['Samsung', '990 Pro', '2000'],
            'psu' => ['Corsair', 'RM850e'],
            'case' => ['Lian', 'Lancool 207'],
            'cooler' => ['ARCTIC', 'Liquid Freezer III']
        ]
    ],
    [
        'name' => 'Next-Gen Enthusiast - Ryzen 9 9950X3D + RTX 5090',
        'description' => 'Ultimate flagship build with cutting-edge components. Dominates 4K gaming and professional workloads with uncompromising performance.',
        'budget_range' => 'enthusiast',
        'components' => [
            'cpu' => ['AMD', 'Ryzen 9 9950X3D'],
            'motherboard' => ['Gigabyte', 'X870E AORUS'],
            'gpu' => ['', 'RTX 5090'],
            'ram' => ['Corsair', 'Vengeance RGB 64', '6000'],
            'storage' => ['Samsung', '990 Pro', '4000'],
            'psu' => ['Corsair', 'RM1000e'],
            'case' => ['NZXT', 'H9 Flow'],
            'cooler' => ['ARCTIC', 'Liquid Freezer III Pro 360']
        ]
    ]
];

foreach ($builds as $buildData) {
    echo "🔧 Creating: {$buildData['name']}\n";
    
    $selectedComponents = [];
    $totalPrice = 0;
    
    foreach ($buildData['components'] as $category => $search) {
        $brand = $search[0];
        $name = $search[1];
        $extra = $search[2] ?? '';
        
        // Try to find the component
        $component = null;
        
        if ($category === 'storage' && $extra) {
            // For storage, search by capacity
            $component = DB::table('components')
                ->where('category', $category)
                ->where('brand', 'like', "%{$brand}%")
                ->where('raw_name', 'like', "%{$name}%")
                ->whereRaw("JSON_EXTRACT(specs, '$.capacity_gb') = ?", [$extra])
                ->first();
        } elseif ($category === 'ram' && $extra) {
            // For RAM, search by speed
            $component = DB::table('components')
                ->where('category', $category)
                ->where('brand', 'like', "%{$brand}%")
                ->where('raw_name', 'like', "%{$name}%")
                ->whereRaw("JSON_EXTRACT(specs, '$.speed_mhz') >= ?", [$extra])
                ->first();
        } elseif ($category === 'psu') {
            // For PSU, search by wattage
            $component = DB::table('components')
                ->where('category', $category)
                ->whereRaw("JSON_EXTRACT(specs, '$.wattage') >= ?", [$name])
                ->orderBy(DB::raw("JSON_EXTRACT(specs, '$.wattage')"), 'asc')
                ->first();
        } elseif (empty($brand)) {
            // Search by name only
            $component = DB::table('components')
                ->where('category', $category)
                ->where('raw_name', 'like', "%{$name}%")
                ->first();
        } else {
            // Normal search
            $component = findComponent($category, $brand, $name);
        }
        
        if ($component) {
            $selectedComponents[$category] = $component->id;
            
            // Get price
            $price = DB::table('prices')
                ->where('component_id', $component->id)
                ->first();
            
            if ($price) {
                $totalPrice += $price->price_bdt;
            }
            
            echo "   ✅ {$category}: {$component->brand} {$component->model}\n";
        } else {
            echo "   ⚠️  {$category}: Not found (searched for: {$brand} {$name})\n";
        }
    }
    
    // Create build if we have components
    if (count($selectedComponents) >= 5) {
        $buildId = DB::table('builds')->insertGetId([
            'user_id' => $userId,
            'name' => $buildData['name'],
            'description' => $buildData['description'],
            'cpu_id' => $selectedComponents['cpu'] ?? null,
            'motherboard_id' => $selectedComponents['motherboard'] ?? null,
            'gpu_id' => $selectedComponents['gpu'] ?? null,
            'ram_id' => $selectedComponents['ram'] ?? null,
            'storage_id' => $selectedComponents['storage'] ?? null,
            'psu_id' => $selectedComponents['psu'] ?? null,
            'case_id' => $selectedComponents['case'] ?? null,
            'cooler_id' => $selectedComponents['cooler'] ?? null,
            'total_price' => $totalPrice,
            'is_public' => true,
            'is_featured' => true,
            'created_at' => now(),
            'updated_at' => now()
        ]);
        
        echo "   💰 Total Price: ৳" . number_format($totalPrice, 2) . "\n";
        echo "   🎉 Build created with ID: {$buildId}\n";
    } else {
        echo "   ❌ Not enough components found, skipping build\n";
    }
    
    echo "\n";
}

echo "═══════════════════════════════════════════════\n";
echo "✨ Sample Builds Created!\n";
echo "═══════════════════════════════════════════════\n";

$buildCount = DB::table('builds')->count();
echo "📊 Total builds in database: {$buildCount}\n";
echo "\n🎉 Done!\n";
