# RigCheck Web - Quick Start Guide

## 🚀 Fast Deployment to Hostinger

This guide gets you deployed in **30 minutes or less**.

## Prerequisites

- Hostinger VPS or Business hosting account
- Domain name pointed to Hostinger
- SSH access enabled in hPanel

## Step-by-Step (30 Minutes)

### 1. Push to GitHub (5 min)

```bash
# On your local machine
cd rigcheck-web-deploy

# Create new repository on GitHub, then:
git remote add origin https://github.com/YOUR_USERNAME/rigcheck-web.git
git push -u origin main
```

### 2. Connect to Hostinger (2 min)

```bash
ssh u123456789@ssh.hostinger.com -p 65002
# Replace u123456789 with your Hostinger username
```

### 3. Install Node.js (3 min)

For VPS:
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
node -v  # Should show v20.x.x
```

For Shared/Business: Node.js is pre-installed, skip this step.

### 4. Clone Your Repository (2 min)

```bash
cd ~/public_html  # or /var/www/html for VPS
rm -f index.html  # Remove default page
git clone https://github.com/YOUR_USERNAME/rigcheck-web.git .
```

### 5. Configure Environment (3 min)

```bash
cp .env.example .env.local
nano .env.local
```

**Update these 3 critical values:**
```env
NEXT_PUBLIC_API_BASE_URL=https://api.yourdomain.com/api/v1
NEXT_PUBLIC_SITE_URL=https://yourdomain.com
NEXTAUTH_SECRET=$(openssl rand -base64 32)
```

Save and exit (Ctrl+X, Y, Enter).

### 6. Install Dependencies (5 min)

```bash
npm install
```

### 7. Build Application (5 min)

```bash
npm run build
```

### 8. Install & Start PM2 (3 min)

```bash
npm install -g pm2
pm2 start npm --name "rigcheck-web" -- start
pm2 save
pm2 startup  # Run the command it outputs
```

### 9. Set Up Nginx (VPS Only - 2 min)

```bash
sudo apt install nginx -y

# Create config
sudo nano /etc/nginx/sites-available/rigcheck
```

Paste this:
```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Enable and restart:
```bash
sudo ln -s /etc/nginx/sites-available/rigcheck /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 10. Add SSL Certificate (3 min)

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

Follow prompts (choose redirect HTTP to HTTPS).

## ✅ Done!

Visit `https://yourdomain.com` - Your site is live!

## Common Commands

```bash
# View logs
pm2 logs rigcheck-web

# Restart app
pm2 restart rigcheck-web

# Deploy updates
cd ~/public_html
git pull
npm install
npm run build
pm2 restart rigcheck-web
```

## Troubleshooting

**Site not loading?**
```bash
pm2 status  # Check if running
pm2 logs    # Check for errors
```

**Port 3000 in use?**
```bash
lsof -i :3000
kill -9 <PID>
pm2 restart rigcheck-web
```

**Build fails?**
```bash
node -v  # Must be v18 or higher
npm cache clean --force
rm -rf node_modules
npm install
npm run build
```

## Need Help?

1. Check [HOSTINGER_DEPLOYMENT.md](./HOSTINGER_DEPLOYMENT.md) for detailed guide
2. Contact Hostinger support (24/7 live chat)
3. Check PM2 logs: `pm2 logs rigcheck-web`

## Next Steps

- [ ] Test all website features
- [ ] Deploy API backend (see API_DEPLOYMENT.md)
- [ ] Set up automatic deployment script
- [ ] Configure Cloudflare for CDN
- [ ] Enable monitoring
