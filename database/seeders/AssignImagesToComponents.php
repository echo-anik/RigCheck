<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Component;
use Illuminate\Support\Facades\DB;

class AssignImagesToComponents extends Seeder
{
    /**
     * Assign temporary images to components that don't have images.
     */
    public function run(): void
    {
        $this->command->info('🖼️  Assigning temporary images to components...');

        // Base URL for images
        $baseUrl = 'https://yellow-dinosaur-111977.hostingersite.com/images';

        // Get all components without images
        $components = Component::whereNull('primary_image_url')
            ->orWhere('primary_image_url', '')
            ->get();

        $this->command->info("Found {$components->count()} components without images");

        // We have 26 images (image (1).jpg to image (26).jpg)
        $totalImages = 26;
        $imageIndex = 1;

        $updated = 0;

        foreach ($components as $component) {
            // Cycle through available images
            $imageFilename = "image ({$imageIndex}).jpg";
            $imageUrl = "{$baseUrl}/{$imageFilename}";

            // Update the component
            $component->primary_image_url = $imageUrl;
            $component->image_urls = json_encode([$imageUrl]);
            $component->save();

            $updated++;

            // Cycle to next image
            $imageIndex++;
            if ($imageIndex > $totalImages) {
                $imageIndex = 1; // Reset to first image
            }

            if ($updated % 100 === 0) {
                $this->command->info("Updated {$updated} components...");
            }
        }

        $this->command->info("✅ Successfully assigned images to {$updated} components!");
        $this->command->info("Images are available at: {$baseUrl}/image (1).jpg through image (26).jpg");
    }
}
