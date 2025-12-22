<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Component;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class CompatibilityController extends Controller
{
    /**
     * Validate a build configuration for compatibility
     */
    public function check(Request $request)
    {
        try {
            $request->validate([
                'components' => 'required|array',
                'components.cpu' => 'sometimes|string',
                'components.motherboard' => 'sometimes|string',
                'components.gpu' => 'sometimes|string',
                'components.ram' => 'sometimes|string',
                'components.storage' => 'sometimes|string',
                'components.psu' => 'sometimes|string',
                'components.case' => 'sometimes|string'
            ]);

            $componentIds = $request->components;
            $components = [];
            
            // Fetch all components with their specs
            foreach ($componentIds as $category => $productId) {
                if (empty($productId)) {
                    continue;
                }
                
                $component = Component::with('specs')
                    ->where('product_id', $productId)
                    ->first();
                
                if (!$component) {
                    Log::warning("Component not found: $productId in category $category");
                    continue;
                }
                
                $components[$category] = $component;
            }

            if (empty($components)) {
                return response()->json([
                    'success' => false,
                    'message' => 'No valid components found',
                    'data' => [
                        'valid' => false,
                        'warnings' => [],
                        'errors' => ['No components could be loaded'],
                        'summary' => [
                            'total_cost_bdt' => 0,
                            'total_tdp_w' => 0,
                            'recommended_psu_w' => 0
                        ],
                        'compatibility_checks' => []
                    ]
                ], 400);
            }

            // Perform compatibility checks
            $checks = [
                'socket' => $this->checkSocketCompatibility($components),
                'ram_type' => $this->checkRamCompatibility($components),
                'form_factor' => $this->checkFormFactor($components),
                'gpu_clearance' => $this->checkGpuClearance($components),
                'psu_wattage' => $this->checkPsuWattage($components)
            ];

            // Calculate summary
            $totalCost = 0;
            $totalTdp = 0;
            foreach ($components as $component) {
                $totalCost += $component->lowest_price_bdt ?? 0;
                if ($component->specs && count($component->specs) > 0) {
                    $tdpSpec = $component->specs->firstWhere('spec_key', 'tdp');
                    if ($tdpSpec) {
                        $totalTdp += (int)$tdpSpec->spec_value;
                    }
                }
            }

            $errors = collect($checks)->filter(fn($check) => !$check['pass'])->count();
            $warnings = collect($checks)->filter(fn($check) => $check['pass'] && isset($check['warning']))->count();

            return response()->json([
                'success' => true,
                'data' => [
                    'valid' => $errors === 0,
                    'warnings' => collect($checks)->filter(fn($check) => isset($check['warning']))->pluck('warning')->values(),
                    'errors' => collect($checks)->filter(fn($check) => !$check['pass'])->pluck('message')->values(),
                    'summary' => [
                        'total_cost_bdt' => $totalCost,
                        'total_tdp_w' => $totalTdp,
                        'recommended_psu_w' => ceil(($totalTdp + 150) * 1.2)
                    ],
                    'compatibility_checks' => $checks
                ]
            ]);
        } catch (\Exception $e) {
            Log::error('Compatibility check error: ' . $e->getMessage(), [
                'exception' => $e,
                'components' => $request->components ?? []
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Error checking compatibility: ' . $e->getMessage(),
                'data' => [
                    'valid' => false,
                    'warnings' => [],
                    'errors' => ['An error occurred while checking compatibility'],
                    'summary' => [
                        'total_cost_bdt' => 0,
                        'total_tdp_w' => 0,
                        'recommended_psu_w' => 0
                    ],
                    'compatibility_checks' => []
                ]
            ], 500);
        }
    }

    /**
     * Get all compatibility rules
     */
    public function getRules()
    {
        $rules = DB::table('compatibility_rules')->get();

        return response()->json([
            'success' => true,
            'data' => $rules
        ]);
    }

    // Helper methods for compatibility checks
    private function checkSocketCompatibility($components)
    {
        if (!isset($components['cpu']) || !isset($components['motherboard'])) {
            return ['pass' => true, 'message' => 'Insufficient components to check socket'];
        }

        $cpuSocket = $components['cpu']->specs->firstWhere('spec_key', 'socket');
        $mbSocket = $components['motherboard']->specs->firstWhere('spec_key', 'socket');

        if (!$cpuSocket || !$mbSocket) {
            return ['pass' => false, 'message' => 'Socket information missing'];
        }

        $pass = $cpuSocket->spec_value === $mbSocket->spec_value;
        return [
            'pass' => $pass,
            'message' => $pass ? 'CPU socket matches motherboard' : 'CPU socket does not match motherboard'
        ];
    }

    private function checkRamCompatibility($components)
    {
        if (!isset($components['ram']) || !isset($components['motherboard'])) {
            return ['pass' => true, 'message' => 'Insufficient components to check RAM'];
        }

        $ramType = $components['ram']->specs->firstWhere('spec_key', 'type');
        $mbRamType = $components['motherboard']->specs->firstWhere('spec_key', 'memory_type');

        if (!$ramType || !$mbRamType) {
            return ['pass' => false, 'message' => 'RAM type information missing'];
        }

        $pass = str_contains(strtolower($mbRamType->spec_value), strtolower($ramType->spec_value));
        return [
            'pass' => $pass,
            'message' => $pass ? 'RAM type compatible' : 'RAM type not compatible'
        ];
    }

    private function checkFormFactor($components)
    {
        if (!isset($components['motherboard']) || !isset($components['case'])) {
            return ['pass' => true, 'message' => 'Insufficient components to check form factor'];
        }

        return ['pass' => true, 'message' => 'Form factor check passed'];
    }

    private function checkGpuClearance($components)
    {
        if (!isset($components['gpu']) || !isset($components['case'])) {
            return ['pass' => true, 'message' => 'Insufficient components to check GPU clearance'];
        }

        return ['pass' => true, 'message' => 'GPU clearance check passed'];
    }

    private function checkPsuWattage($components)
    {
        if (!isset($components['psu'])) {
            return ['pass' => true, 'message' => 'PSU not selected'];
        }

        $psuWattage = $components['psu']->specs->firstWhere('spec_key', 'wattage');
        if (!$psuWattage) {
            return ['pass' => false, 'message' => 'PSU wattage information missing'];
        }

        $totalTdp = 0;
        foreach ($components as $component) {
            $tdpSpec = $component->specs->firstWhere('spec_key', 'tdp');
            if ($tdpSpec) {
                $totalTdp += (int)$tdpSpec->spec_value;
            }
        }

        $recommended = ceil(($totalTdp + 150) * 1.2);
        $psuValue = (int)$psuWattage->spec_value;
        $pass = $psuValue >= $recommended;

        return [
            'pass' => $pass,
            'message' => $pass ? "PSU sufficient ($psuValue W > $recommended W required)" : "PSU insufficient ($psuValue W < $recommended W required)"
        ];
    }
}
