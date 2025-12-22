#!/bin/bash

# RigCheck API Setup Script
# This script initializes the Laravel project with Docker

echo "========================================"
echo "RigCheck API - Docker Setup"
echo "========================================"

# Step 1: Build and start Docker containers
echo ""
echo "Step 1: Building Docker containers..."
docker-compose up -d --build

# Wait for MySQL to be ready
echo ""
echo "Waiting for MySQL to initialize (30 seconds)..."
sleep 30

# Step 2: Install Laravel via Composer
echo ""
echo "Step 2: Creating Laravel project..."
docker-compose exec -T app composer create-project --prefer-dist laravel/laravel:^10.0 temp-laravel

# Move Laravel files to root
docker-compose exec -T app bash -c "shopt -s dotglob && mv temp-laravel/* . && rm -rf temp-laravel"

# Step 3: Set up environment
echo ""
echo "Step 3: Configuring environment..."
docker-compose exec -T app cp .env.example .env

# Update .env with Docker database settings
docker-compose exec -T app bash -c "sed -i 's/DB_HOST=127.0.0.1/DB_HOST=db/g' .env"
docker-compose exec -T app bash -c "sed -i 's/DB_DATABASE=laravel/DB_DATABASE=pc_builder_rigcheck/g' .env"
docker-compose exec -T app bash -c "sed -i 's/DB_USERNAME=root/DB_USERNAME=rigcheck_user/g' .env"
docker-compose exec -T app bash -c "sed -i 's/DB_PASSWORD=/DB_PASSWORD=rigcheck_password/g' .env"
docker-compose exec -T app bash -c "sed -i 's/CACHE_DRIVER=file/CACHE_DRIVER=redis/g' .env"
docker-compose exec -T app bash -c "sed -i 's/REDIS_HOST=127.0.0.1/REDIS_HOST=redis/g' .env"

# Generate application key
docker-compose exec -T app php artisan key:generate

# Step 4: Install Laravel Sanctum
echo ""
echo "Step 4: Installing Laravel Sanctum..."
docker-compose exec -T app composer require laravel/sanctum

# Publish Sanctum config
docker-compose exec -T app php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"

# Step 5: Set up permissions
echo ""
echo "Step 5: Setting permissions..."
docker-compose exec -T app chmod -R 775 storage bootstrap/cache

# Step 6: Run migrations
echo ""
echo "Step 6: Running database migrations..."
docker-compose exec -T app php artisan migrate --force

# Step 7: Create storage link
docker-compose exec -T app php artisan storage:link

# Step 8: Clear caches
echo ""
echo "Step 8: Clearing caches..."
docker-compose exec -T app php artisan config:clear
docker-compose exec -T app php artisan cache:clear
docker-compose exec -T app php artisan route:clear

echo ""
echo "========================================"
echo "Setup Complete!"
echo "========================================"
echo ""
echo "Access Points:"
echo "  - API: http://localhost:8000"
echo "  - PHPMyAdmin: http://localhost:8080"
echo ""
echo "Database:"
echo "  - Host: localhost:3307"
echo "  - Database: pc_builder_rigcheck"
echo "  - Username: rigcheck_user"
echo "  - Password: rigcheck_password"
echo ""
echo "Next Steps:"
echo "  1. Import component data:"
echo "     docker-compose exec -T db mysql -u rigcheck_user -prigcheck_password pc_builder_rigcheck < ../import_components.sql"
echo ""
echo "  2. Import component specs:"
echo "     docker-compose exec -T db mysql -u rigcheck_user -prigcheck_password pc_builder_rigcheck < ../import_component_specs.sql"
echo ""
echo "  3. View logs:"
echo "     docker-compose logs -f app"
echo ""
echo "========================================"
