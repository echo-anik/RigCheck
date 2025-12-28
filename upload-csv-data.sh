#!/bin/bash

# Upload CSV files to Hostinger server
echo "📤 Uploading CSV files to Hostinger..."

scp -P 65002 -r ../data/csv u713301745@us-bos-web1679.hosting-servers.com:~/domains/yellow-dinosaur-111977.hostingersite.com/laravel-app/data/

echo "✅ CSV files uploaded!"
echo ""
echo "Now run on server:"
echo "cd ~/domains/yellow-dinosaur-111977.hostingersite.com/laravel-app"
echo "php artisan db:seed"
