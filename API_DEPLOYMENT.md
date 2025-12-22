# RigCheck API - Backend Deployment Guide

## Overview

This guide covers deploying the RigCheck Laravel API backend that the website will connect to.

## Prerequisites

- Hostinger VPS or Cloud Hosting
- MySQL database access
- Domain/subdomain for API (e.g., api.yourdomain.com)
- PHP 8.2+ support
- Composer installed

## Option 1: Deploy API on Same Hostinger Server

### Folder Structure
```
/var/www/
├── html/                    (Next.js website)
└── rigcheck-api/           (Laravel API)
```

### Steps

1. **Navigate to web root:**
```bash
cd /var/www
sudo mkdir rigcheck-api
sudo chown $USER:$USER rigcheck-api
cd rigcheck-api
```

2. **Clone API repository:**
```bash
git clone https://github.com/YOUR_USERNAME/rigcheck-api.git .
```

3. **Install PHP dependencies:**
```bash
composer install --no-dev --optimize-autoloader
```

4. **Configure environment:**
```bash
cp .env.example .env
nano .env
```

Update `.env`:
```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.yourdomain.com

DB_HOST=localhost
DB_DATABASE=rigcheck_production
DB_USERNAME=rigcheck_user
DB_PASSWORD=your-secure-password

# Add your actual values for:
JWT_SECRET=
MAIL_* settings
AWS_* settings (if using S3)
```

5. **Generate app key:**
```bash
php artisan key:generate
```

6. **Set up database:**
```bash
# Create database
mysql -u root -p

CREATE DATABASE rigcheck_production CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'rigcheck_user'@'localhost' IDENTIFIED BY 'your-secure-password';
GRANT ALL PRIVILEGES ON rigcheck_production.* TO 'rigcheck_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# Run migrations
php artisan migrate --force
php artisan db:seed --force
```

7. **Set permissions:**
```bash
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
```

8. **Optimize Laravel:**
```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### Configure Nginx for API

Create `/etc/nginx/sites-available/rigcheck-api`:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name api.yourdomain.com;
    root /var/www/rigcheck-api/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;
    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/rigcheck-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Add SSL for API

```bash
sudo certbot --nginx -d api.yourdomain.com
```

## Option 2: Deploy API on Separate Server

If you want to separate concerns:

- **Website Server:** Hostinger (Next.js)
- **API Server:** DigitalOcean/AWS/Another Hostinger VPS (Laravel)

Follow the same steps above but on a different server.

**Benefits:**
- Better scalability
- Isolate resources
- Can optimize each server for its purpose

## Configure CORS for Website

In your Laravel API, update `config/cors.php`:

```php
return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => [
        'https://yourdomain.com',
        'https://www.yourdomain.com',
    ],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
```

## Set Up Queue Worker

For background jobs:

```bash
sudo nano /etc/systemd/system/rigcheck-queue.service
```

```ini
[Unit]
Description=RigCheck Queue Worker
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
Restart=always
RestartSec=3
ExecStart=/usr/bin/php /var/www/rigcheck-api/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600

[Install]
WantedBy=multi-user.target
```

Start queue worker:
```bash
sudo systemctl enable rigcheck-queue
sudo systemctl start rigcheck-queue
sudo systemctl status rigcheck-queue
```

## Set Up Scheduler

Add to crontab:
```bash
crontab -e
```

Add:
```cron
* * * * * cd /var/www/rigcheck-api && php artisan schedule:run >> /dev/null 2>&1
```

## Update Website API Configuration

After API is deployed, update your website's `.env.local`:

```env
NEXT_PUBLIC_API_BASE_URL=https://api.yourdomain.com/api/v1
NEXT_PUBLIC_API_URL=https://api.yourdomain.com/api/v1
```

Rebuild and restart website:
```bash
cd ~/public_html  # or wherever your website is
npm run build
pm2 restart rigcheck-web
```

## Test API Connection

```bash
# Test API endpoint
curl https://api.yourdomain.com/api/v1/health

# Should return:
# {"status":"ok","timestamp":"2024-..."}
```

From your website:
```bash
curl https://yourdomain.com/api/test
```

## Monitoring API

### View Laravel Logs
```bash
tail -f /var/www/rigcheck-api/storage/logs/laravel.log
```

### Monitor Queue Worker
```bash
sudo systemctl status rigcheck-queue
sudo journalctl -u rigcheck-queue -f
```

### Monitor PHP-FPM
```bash
sudo systemctl status php8.2-fpm
```

## API Update Script

Create `~/update-api.sh`:

```bash
#!/bin/bash
cd /var/www/rigcheck-api

echo "Pulling latest changes..."
git pull origin main

echo "Installing dependencies..."
composer install --no-dev --optimize-autoloader

echo "Running migrations..."
php artisan migrate --force

echo "Clearing caches..."
php artisan cache:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "Restarting services..."
sudo systemctl restart php8.2-fpm
sudo systemctl restart rigcheck-queue

echo "API updated successfully!"
```

Make executable:
```bash
chmod +x ~/update-api.sh
```

## Database Backups

Create `~/backup-api-db.sh`:

```bash
#!/bin/bash
BACKUP_DIR=~/backups/rigcheck-db
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="rigcheck_production"
DB_USER="rigcheck_user"
DB_PASS="your-password"

mkdir -p $BACKUP_DIR

mysqldump -u $DB_USER -p$DB_PASS $DB_NAME | gzip > $BACKUP_DIR/db_$DATE.sql.gz

# Keep last 7 days
find $BACKUP_DIR -name "db_*.sql.gz" -mtime +7 -delete

echo "Database backup complete: db_$DATE.sql.gz"
```

Schedule daily:
```bash
crontab -e
```

Add:
```cron
0 2 * * * ~/backup-api-db.sh
```

## Security Checklist

- [ ] `.env` file not in Git
- [ ] `APP_DEBUG=false` in production
- [ ] Database password is strong
- [ ] JWT secret is generated
- [ ] CORS configured correctly
- [ ] Rate limiting enabled
- [ ] SSL certificate installed
- [ ] Firewall rules configured
- [ ] Regular backups scheduled
- [ ] Queue worker running
- [ ] Scheduler configured

## Troubleshooting

### 500 Internal Server Error

Check Laravel logs:
```bash
tail -f /var/www/rigcheck-api/storage/logs/laravel.log
```

Check Nginx error logs:
```bash
sudo tail -f /var/log/nginx/error.log
```

### Database Connection Failed

Test connection:
```bash
php artisan tinker
>>> DB::connection()->getPdo();
```

### Queue Not Processing

```bash
sudo systemctl status rigcheck-queue
sudo systemctl restart rigcheck-queue
sudo journalctl -u rigcheck-queue -n 50
```

### Permission Denied

```bash
sudo chown -R www-data:www-data /var/www/rigcheck-api/storage
sudo chmod -R 775 /var/www/rigcheck-api/storage
```

## Performance Optimization

### Enable OPcache

Edit `/etc/php/8.2/fpm/php.ini`:
```ini
opcache.enable=1
opcache.memory_consumption=256
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=10000
opcache.revalidate_freq=60
```

Restart PHP-FPM:
```bash
sudo systemctl restart php8.2-fpm
```

### Redis Caching

Install Redis:
```bash
sudo apt install redis-server -y
sudo systemctl enable redis-server
```

Update `.env`:
```env
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis
```

## Complete Architecture

```
                         Internet
                            |
                    [Cloudflare CDN]
                            |
              +-------------+-------------+
              |                           |
     [Website Server]              [API Server]
    yourdomain.com            api.yourdomain.com
         |                           |
    [Next.js App]              [Laravel API]
      Port 3000                     |
         |                     [MySQL DB]
      [Nginx]                  [Redis Cache]
    Port 80/443               [Queue Worker]
```

## Next Steps

1. Deploy API following this guide
2. Update website environment variables
3. Test API connectivity from website
4. Set up monitoring
5. Configure automatic backups
6. Set up alerts for downtime

---

For website deployment, see [HOSTINGER_DEPLOYMENT.md](./HOSTINGER_DEPLOYMENT.md)
