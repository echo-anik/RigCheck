# Deploy RigCheck to Hostinger - Simple Guide

## Step 1: SSH to Hostinger
```bash
ssh u713301745@ssh.hostinger.com -p 65002
```

## Step 2: Navigate & Clone
```bash
cd ~/domains/yellow-dinosaur-111977.hostingersite.com
mkdir public_html
cd public_html
git clone -b api https://github.com/echo-anik/RigCheck.git .
```

## Step 3: Setup Database in hPanel
1. Go to: https://hpanel.hostinger.com/
2. **Databases** → **MySQL Databases** → **Create New**
3. Fill:
   - Database: `rigcheck`
   - Username: `rigcheck`
   - Password: `Rigcheck@1`
4. Click Create (note the actual names: `u713301745_rigcheck`)

## Step 4: Import SQL
1. **Databases** → **phpMyAdmin**
2. Select: `u713301745_rigcheck`
3. **Import** → Choose `rigcheck_database.sql`
4. Click **Go**

## Step 5: Configure .env
```bash
cp .env.hostinger .env
nano .env
```

Update these lines with ACTUAL database name from hPanel:
```
DB_DATABASE=u713301745_rigcheck
DB_USERNAME=u713301745_rigcheck
DB_PASSWORD=Rigcheck@1
```

Save: Ctrl+X, Y, Enter

## Step 6: Deploy
```bash
chmod +x deploy-hostinger.sh
./deploy-hostinger.sh
```

When asked about migrations, type: `N`

## Step 7: Point Domain to /public
In hPanel:
1. **Websites** → yellow-dinosaur...
2. **Manage** → **Advanced** → **Website Root**
3. Change to: `/domains/yellow-dinosaur-111977.hostingersite.com/public_html/public`
4. **Save**

## Done!
Visit: https://yellow-dinosaur-111977.hostingersite.com

Login: admin@rigcheck.com / admin123
