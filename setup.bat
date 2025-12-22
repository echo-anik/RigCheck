@echo off
REM RigCheck API Setup Script for Windows
REM This script initializes the Laravel project with Docker

echo ========================================
echo RigCheck API - Docker Setup
echo ========================================

REM Step 1: Build and start Docker containers
echo.
echo Step 1: Building Docker containers...
docker-compose up -d --build

REM Wait for MySQL to be ready
echo.
echo Waiting for MySQL to initialize (30 seconds)...
timeout /t 30 /nobreak

REM Step 2: Install Laravel via Composer
echo.
echo Step 2: Creating Laravel project...
docker-compose exec -T app composer create-project --prefer-dist laravel/laravel:^10.0 temp-laravel

REM Move Laravel files to root
docker-compose exec -T app bash -c "shopt -s dotglob && mv temp-laravel/* . && rm -rf temp-laravel"

REM Step 3: Copy environment file
echo.
echo Step 3: Configuring environment...
docker-compose exec -T app cp .env.example .env

REM Generate application key
docker-compose exec -T app php artisan key:generate

REM Step 4: Install Laravel Sanctum
echo.
echo Step 4: Installing Laravel Sanctum...
docker-compose exec -T app composer require laravel/sanctum

REM Publish Sanctum config
docker-compose exec -T app php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"

REM Step 5: Set up permissions
echo.
echo Step 5: Setting permissions...
docker-compose exec -T app chmod -R 775 storage bootstrap/cache

REM Step 6: Run migrations (database schema already imported)
echo.
echo Step 6: Running database migrations...
docker-compose exec -T app php artisan migrate --force

REM Step 7: Create storage link
docker-compose exec -T app php artisan storage:link

REM Step 8: Clear caches
echo.
echo Step 8: Clearing caches...
docker-compose exec -T app php artisan config:clear
docker-compose exec -T app php artisan cache:clear
docker-compose exec -T app php artisan route:clear

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Access Points:
echo   - API: http://localhost:8000
echo   - PHPMyAdmin: http://localhost:8080
echo.
echo Database:
echo   - Host: localhost:3307
echo   - Database: pc_builder_rigcheck
echo   - Username: rigcheck_user
echo   - Password: rigcheck_password
echo.
echo Next Steps:
echo   1. Import component data:
echo      docker-compose exec -T db mysql -u rigcheck_user -prigcheck_password pc_builder_rigcheck ^< ..\import_components.sql
echo.
echo   2. Import component specs:
echo      docker-compose exec -T db mysql -u rigcheck_user -prigcheck_password pc_builder_rigcheck ^< ..\import_component_specs.sql
echo.
echo   3. View logs:
echo      docker-compose logs -f app
echo.
echo ========================================
pause
