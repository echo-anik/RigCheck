<?php

namespace Database\Seeders;

// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            ComponentSeeder::class,       // Import components first
            ComponentSpecSeeder::class,   // Then populate specs from CSV
            AdminUserSeeder::class,       // Create admin user
            PresetBuildSeeder::class,     // Create 10 ready-made builds as admin
        ]);
    }
}
