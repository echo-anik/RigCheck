<?php

namespace App\Http\Controllers\Api\Web;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;

class BuilderDataController extends Controller
{
    /**
     * Get a highly optimized, compact list of all components for the PC Builder.
     * Bypasses Eloquent ORM to load 17,000+ components in under a second.
     */
    public function getBuilderData()
    {
        // Cache the result for 12 hours since component data doesn't change by the minute.
        $data = Cache::remember('builder_components_compact', 60 * 60 * 12, function () {
            
            // 1. Fetch all components with brand names
            $componentsQuery = DB::table('components')
                ->leftJoin('brands', 'components.brand_id', '=', 'brands.id')
                ->select(
                    'components.id',
                    'components.product_id',
                    'components.category',
                    'components.name',
                    'brands.brand_name as brand',
                    'components.lowest_price_bdt',
                    'components.primary_image_url',
                    'components.image_urls'
                )
                // Optionally filter out discontinued items if needed
                ->where('components.availability_status', '!=', 'discontinued')
                ->get();

            // 2. Fetch only the critical specs needed for compatibility checks and badging in the UI
            $criticalSpecKeys = [
                'socket', 'socket_type', 'chipset', 'form_factor', 
                'cores', 'vram_gb', 'capacity_gb', 'speed_mhz', 
                'type', 'wattage', 'efficiency_rating',
                'tdp', 'base_tdp', 'power_consumption', 'recommended_psu', 'suggested_psu'
            ];
            
            $specsQuery = DB::table('component_specs')
                ->select('component_id', 'spec_key', 'spec_value')
                ->whereIn('spec_key', $criticalSpecKeys)
                ->get();
                
            // Group specs by component_id
            $specsByComponent = [];
            foreach ($specsQuery as $spec) {
                if (!isset($specsByComponent[$spec->component_id])) {
                    $specsByComponent[$spec->component_id] = [];
                }
                $specsByComponent[$spec->component_id][$spec->spec_key] = $spec->spec_value;
            }

            // 3. Assemble the final compact payload
            $compactComponents = [];
            foreach ($componentsQuery as $c) {
                // Parse image urls to get the first one if primary is null
                $images = [];
                if ($c->image_urls) {
                    $images = json_decode($c->image_urls, true) ?: [];
                }
                $imageUrl = $c->primary_image_url ?? ($images[0] ?? null);

                $compactComponents[$c->category][] = [
                    'id' => $c->product_id, // map to expected 'id' on frontend
                    'product_id' => $c->product_id,
                    'name' => $c->name,
                    'brand' => $c->brand,
                    'category' => $c->category,
                    'lowest_price_bdt' => $c->lowest_price_bdt,
                    'image_urls' => $imageUrl ? [$imageUrl] : [],
                    'specs' => $specsByComponent[$c->id] ?? (object)[], // ensures empty is {} not []
                ];
            }

            return $compactComponents;
        });

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }
}
