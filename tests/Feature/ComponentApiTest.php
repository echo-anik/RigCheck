<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\Component;
use App\Models\Brand;
use Illuminate\Foundation\Testing\RefreshDatabase;

class ComponentApiTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test getting all components
     */
    public function test_can_get_all_components()
    {
        // Create test data
        $brand = Brand::factory()->create();
        Component::factory()->count(5)->create(['brand_id' => $brand->id]);

        $response = $this->getJson('/api/v1/components');

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'data' => [
                         '*' => [
                             'id',
                             'product_id',
                             'name',
                             'category',
                             'brand',
                             'lowest_price_bdt',
                         ]
                     ],
                     'links',
                     'meta'
                 ]);
    }

    /**
     * Test filtering components by category
     */
    public function test_can_filter_components_by_category()
    {
        $brand = Brand::factory()->create();
        Component::factory()->create(['category' => 'cpu', 'brand_id' => $brand->id]);
        Component::factory()->create(['category' => 'gpu', 'brand_id' => $brand->id]);

        $response = $this->getJson('/api/v1/components?category=cpu');

        $response->assertStatus(200);
        $data = $response->json('data');

        foreach ($data as $component) {
            $this->assertEquals('cpu', $component['category']);
        }
    }

    /**
     * Test getting a single component
     */
    public function test_can_get_single_component()
    {
        $brand = Brand::factory()->create();
        $component = Component::factory()->create(['brand_id' => $brand->id]);

        $response = $this->getJson("/api/v1/components/{$component->product_id}");

        $response->assertStatus(200)
                 ->assertJson([
                     'data' => [
                         'id' => $component->id,
                         'name' => $component->name,
                     ]
                 ]);
    }

    /**
     * Test component not found
     */
    public function test_returns_404_for_nonexistent_component()
    {
        $response = $this->getJson('/api/v1/components/nonexistent-component');

        $response->assertStatus(404);
    }

    /**
     * Test pagination
     */
    public function test_components_are_paginated()
    {
        $brand = Brand::factory()->create();
        Component::factory()->count(30)->create(['brand_id' => $brand->id]);

        $response = $this->getJson('/api/v1/components?per_page=10');

        $response->assertStatus(200)
                 ->assertJsonPath('meta.per_page', 10)
                 ->assertJsonPath('meta.total', 30);
    }

    /**
     * Test search functionality
     */
    public function test_can_search_components()
    {
        $brand = Brand::factory()->create();
        Component::factory()->create([
            'name' => 'Intel Core i5-14600K',
            'brand_id' => $brand->id
        ]);
        Component::factory()->create([
            'name' => 'AMD Ryzen 7 7700X',
            'brand_id' => $brand->id
        ]);

        $response = $this->getJson('/api/v1/components?search=Intel');

        $response->assertStatus(200);
        $data = $response->json('data');

        $this->assertNotEmpty($data);
        foreach ($data as $component) {
            $this->assertStringContainsStringIgnoringCase('intel', $component['name']);
        }
    }

    /**
     * Test filtering by price range
     */
    public function test_can_filter_by_price_range()
    {
        $brand = Brand::factory()->create();
        Component::factory()->create(['lowest_price_bdt' => 10000, 'brand_id' => $brand->id]);
        Component::factory()->create(['lowest_price_bdt' => 50000, 'brand_id' => $brand->id]);
        Component::factory()->create(['lowest_price_bdt' => 100000, 'brand_id' => $brand->id]);

        $response = $this->getJson('/api/v1/components?min_price=20000&max_price=80000');

        $response->assertStatus(200);
        $data = $response->json('data');

        foreach ($data as $component) {
            $price = $component['lowest_price_bdt'];
            $this->assertGreaterThanOrEqual(20000, $price);
            $this->assertLessThanOrEqual(80000, $price);
        }
    }
}
