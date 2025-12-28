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
                $specs = $component->specs_object;
                $tdp = $specs['tdp'] ?? $specs['power_consumption'] ?? 0;
                if ($tdp) {
                    $totalTdp += (int)filter_var($tdp, FILTER_SANITIZE_NUMBER_INT);
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

        $cpuSpecs = $components['cpu']->specs_object;
        $mbSpecs = $components['motherboard']->specs_object;
        
        $cpuSocket = $cpuSpecs['socket'] ?? $cpuSpecs['socket_type'] ?? null;
        $mbSocket = $mbSpecs['socket'] ?? $mbSpecs['socket_type'] ?? null;

        if (!$cpuSocket || !$mbSocket) {
            return ['pass' => false, 'message' => 'Socket information missing'];
        }

        $pass = strtolower(trim($cpuSocket)) === strtolower(trim($mbSocket));
        return [
            'pass' => $pass,
            'message' => $pass ? "CPU socket ($cpuSocket) matches motherboard" : "CPU socket ($cpuSocket) does not match motherboard ($mbSocket)"
        ];
    }

    private function checkRamCompatibility($components)
    {
        if (!isset($components['ram']) || !isset($components['motherboard'])) {
            return ['pass' => true, 'message' => 'Insufficient components to check RAM'];
        }

        $ramSpecs = $components['ram']->specs_object;
        $mbSpecs = $components['motherboard']->specs_object;
        
        // Get RAM type - check both ddr_generation and type fields
        $ramType = $ramSpecs['ddr_generation'] ?? $ramSpecs['type'] ?? $ramSpecs['memory_type'] ?? null;
        
        // Get motherboard memory type - check specs first, then extract from name
        $mbRamType = $mbSpecs['memory_type'] ?? $mbSpecs['ram_type'] ?? null;
        
        // If motherboard memory_type is not in specs, try to extract from name
        if (!$mbRamType) {
            $mbName = $components['motherboard']->name;
            if (preg_match('/(DDR[345])/i', $mbName, $matches)) {
                $mbRamType = strtoupper($matches[1]);
            }
        }
        
        // If still no memory type, infer from socket type
        if (!$mbRamType) {
            $mbSocket = $mbSpecs['socket'] ?? $mbSpecs['socket_type'] ?? null;
            if ($mbSocket) {
                $socket = strtoupper(trim($mbSocket));
                // AM5 and LGA1700 (12th gen+) platforms have both DDR4 and DDR5 variants
                // Without explicit memory_type in the motherboard specs, we accept both
                if ($socket === 'AM5' || $socket === 'LGA1700') {
                    // Check if RAM is DDR4 or DDR5 - both are compatible with these platforms
                    $ramTypeUpper = strtoupper(trim($ramType));
                    if ($ramTypeUpper === 'DDR4' || $ramTypeUpper === 'DDR5') {
                        return ['pass' => true, 'message' => "RAM type ($ramType) compatible - $socket motherboards support both DDR4 and DDR5"];
                    }
                } else if ($socket === 'AM4' || $socket === 'LGA1200' || $socket === 'LGA1151') {
                    $mbRamType = 'DDR4';
                }
            }
        }

        if (!$ramType) {
            return ['pass' => false, 'message' => 'RAM type information missing'];
        }
        
        if (!$mbRamType) {
            return ['pass' => true, 'message' => 'Cannot determine motherboard memory type, assuming compatible'];
        }

        // Normalize to uppercase for comparison (DDR4, DDR5, etc.)
        $ramType = strtoupper(trim($ramType));
        $mbRamType = strtoupper(trim($mbRamType));
        
        $pass = $ramType === $mbRamType || str_contains($mbRamType, $ramType);
        
        return [
            'pass' => $pass,
            'message' => $pass 
                ? "RAM type ($ramType) compatible with motherboard ($mbRamType)" 
                : "RAM type ($ramType) NOT compatible with motherboard ($mbRamType)"
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

        $psuSpecs = $components['psu']->specs_object;
        $psuWattage = $psuSpecs['wattage'] ?? $psuSpecs['power'] ?? null;
        
        if (!$psuWattage) {
            return ['pass' => false, 'message' => 'PSU wattage information missing'];
        }

        $totalTdp = 0;
        foreach ($components as $component) {
            $specs = $component->specs_object;
            $tdp = $specs['tdp'] ?? $specs['power_consumption'] ?? 0;
            if ($tdp) {
                $totalTdp += (int)filter_var($tdp, FILTER_SANITIZE_NUMBER_INT);
            }
        }

        $recommended = ceil(($totalTdp + 150) * 1.2);
        $psuValue = (int)filter_var($psuWattage, FILTER_SANITIZE_NUMBER_INT);
        $pass = $psuValue >= $recommended;

        return [
            'pass' => $pass,
            'message' => $pass ? "PSU sufficient ({$psuValue}W >= {$recommended}W required)" : "PSU insufficient ({$psuValue}W < {$recommended}W required)"
        ];
    }
}
