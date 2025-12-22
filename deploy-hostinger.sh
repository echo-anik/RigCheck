#!/bin/bash

# RigCheck Laravel - Hostinger Deployment Script
# PROPER STRUCTURE: Laravel app in rigcheck-app, public files in public_html

set -e  # Exit on error

echo "================================"
echo "RigCheck Laravel Deployment"
echo "================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Determine where we are and set up paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${GREEN}Setting up proper directory structure...${NC}"

# If we're in public_html, restructure
if [[ "$SCRIPT_DIR" == *"public_html"* ]]; then
    echo "Detected public_html location, restructuring..."
    
    # Move to parent
    cd "$PARENT_DIR"
    
    # Rename public_html to rigcheck-app
    if [ -d "public_html" ] && [ ! -d "rigcheck-app" ]; then
        mv public_html rigcheck-app
        echo "✓ Moved files to rigcheck-app/"
    fi
    
    # Create new public_html with only public folder contents
    mkdir -p public_html
    cp -r rigcheck-app/public/* public_html/
    echo "✓ Created public_html/ with public files"
    
    # Update index.php paths
    sed -i "s|__DIR__.'/../vendor/autoload.php'|__DIR__.'/../rigcheck-app/vendor/autoload.php'|g" public_html/index.php
    sed -i "s|__DIR__.'/../bootstrap/app.php'|__DIR__.'/../rigcheck-app/bootstrap/app.php'|g" public_html/index.php
    echo "✓ Updated index.php paths"
    
    # Now work in rigcheck-app
    cd rigcheck-app
elif [ ! -f "artisan" ]; then
    echo -e "${RED}Error: artisan file not found. Are you in the Laravel root directory?${NC}"
    exit 1
fi

echo -e "${GREEN}Step 1: Checking PHP version...${NC}"
PHP_VERSION=$(php -v | head -n 1 | cut -d " " -f 2 | cut -d "." -f 1,2)
echo "PHP Version: $PHP_VERSION"

if (( $(echo "$PHP_VERSION < 8.1" | bc -l) )); then
    echo -e "${RED}Error: PHP 8.1 or higher required${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Step 2: Checking Composer...${NC}"
if ! command -v composer &> /dev/null; then
    echo -e "${RED}Error: Composer not found${NC}"
    exit 1
fi
composer --version

echo ""
echo -e "${GREEN}Step 3: Setting up environment file...${NC}"
if [ ! -f ".env" ]; then
    if [ -f ".env.hostinger" ]; then
        cp .env.hostinger .env
        echo "Copied .env.hostinger to .env"
    elif [ -f ".env.example" ]; then
        cp .env.example .env
        echo "Copied .env.example to .env"
    else
        echo -e "${RED}Error: No environment file template found${NC}"
        exit 1
    fi
    echo -e "${YELLOW}IMPORTANT: Edit .env file with your database credentials!${NC}"
    echo "Press Enter to continue after editing .env..."
    read
fi

echo ""
echo -e "${GREEN}Step 4: Installing dependencies...${NC}"
composer install --no-dev --optimize-autoloader --no-interaction

echo ""
echo -e "${GREEN}Step 5: Generating application key...${NC}"
php artisan key:generate --force

echo ""
echo -e "${GREEN}Step 6: Generating JWT secret...${NC}"
if php artisan jwt:secret --force 2>/dev/null; then
    echo "JWT secret generated"
else
    echo -e "${YELLOW}JWT package not found, skipping...${NC}"
fi

echo ""
echo -e "${GREEN}Step 7: Setting up storage...${NC}"
php artisan storage:link --force || echo "Storage already linked"

echo ""
echo -e "${GREEN}Step 8: Setting file permissions...${NC}"
chmod -R 775 storage bootstrap/cache
echo "Permissions set"

echo ""
echo -e "${GREEN}Step 9: Running database migrations...${NC}"
echo -e "${YELLOW}Make sure you've imported the SQL file first!${NC}"
echo "Run migrations now? (y/N)"
read -r RUN_MIGRATIONS
if [[ "$RUN_MIGRATIONS" =~ ^[Yy]$ ]]; then
    php artisan migrate --force
else
    echo "Skipping migrations. Run manually: php artisan migrate --force"
fi

echo ""
echo -e "${GREEN}Step 10: Optimizing application...${NC}"
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Next steps:"
echo "1. Import your SQL file to the database"
echo "2. Update .env with correct domain and settings"
echo "3. Configure your web server to point to: $(pwd)/public"
echo "4. Test your application!"
echo ""
echo "Useful commands:"
echo "  php artisan migrate         - Run migrations"
echo "  php artisan optimize:clear  - Clear all caches"
echo "  php artisan serve          - Test locally (dev only)"
echo ""
