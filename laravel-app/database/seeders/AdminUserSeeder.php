<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create admin user
        $admin = User::firstOrCreate(
            ['email' => 'admin@rigcheck.com'],
            [
                'name' => 'Admin',
                'password' => Hash::make('Admin@123456'),
                'role' => 'admin',
                'is_banned' => false,
                'email_verified_at' => now(),
            ]
        );

        echo "\n✅ Admin user created/verified:\n";
        echo "   Email: admin@rigcheck.com\n";
        echo "   Password: Admin@123456\n";
        echo "   Role: admin\n\n";
    }
}
