# RigCheck Web - Hostinger Deployment Guide

## Prerequisites

Before deploying to Hostinger, ensure you have:
- [ ] Hostinger hosting account (VPS or Business/Premium hosting with Node.js support)
- [ ] Domain name configured in Hostinger
- [ ] Git installed on your local machine
- [ ] SSH access to your Hostinger server
- [ ] Node.js 18.x or higher support on Hostinger

## Step 1: Prepare Your Hostinger Account

### 1.1 Choose the Right Hosting Plan

**Recommended Plans:**
- **VPS Hosting** (Recommended) - Full control, Node.js support
- **Business Hosting** - Managed with Node.js support
- **Premium Hosting** - Limited Node.js capabilities

### 1.2 Set Up Your Domain

1. Log into Hostinger control panel (hPanel)
2. Go to **Domains** → **DNS/Name Servers**
3. Add/Verify your domain is pointing to your hosting

## Step 2: Set Up Git Repository

### 2.1 Create a Git Repository

**Option A: GitHub (Recommended)**
```bash
# On your local machine
cd rigcheck-web-deploy

# Create a new repository on GitHub first, then:
git remote add origin https://github.com/YOUR_USERNAME/rigcheck-web.git
git branch -M main
git push -u origin main
```

**Option B: GitLab or Bitbucket**
- Follow similar steps with your preferred Git provider

### 2.2 Generate Deploy Key (Optional but Recommended)

On your Hostinger server:
```bash
ssh-keygen -t ed25519 -C "deploy@rigcheck"
cat ~/.ssh/id_ed25519.pub
```

Add this public key to your Git repository's deploy keys.

## Step 3: Connect to Your Hostinger Server

### 3.1 Enable SSH Access

1. Log into hPanel
2. Go to **Advanced** → **SSH Access**
3. Enable SSH access
4. Note your SSH credentials:
   - **Host**: ssh.hostinger.com (or your server IP)
   - **Port**: 65002 (default Hostinger SSH port)
   - **Username**: u123456789 (your Hostinger username)

### 3.2 Connect via SSH

```bash
ssh u123456789@ssh.hostinger.com -p 65002
```

Or if you have a VPS:
```bash
ssh root@your-vps-ip
```

## Step 4: Install Node.js on Hostinger

### For VPS Hosting:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 20.x LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installation
node -v
npm -v
```

### For Shared/Business Hosting:

Node.js is usually pre-installed. Check with:
```bash
node -v
npm -v
```

If not available, contact Hostinger support to enable Node.js for your account.

## Step 5: Clone and Set Up the Application

### 5.1 Navigate to Your Web Root

```bash
# For VPS
cd /var/www/html

# For Shared Hosting (replace u123456789 with your username)
cd ~/public_html
```

### 5.2 Clone Repository

```bash
# Remove default files if needed
rm -rf index.html

# Clone your repository
git clone https://github.com/YOUR_USERNAME/rigcheck-web.git .

# Or using SSH
git clone git@github.com:YOUR_USERNAME/rigcheck-web.git .
```

### 5.3 Install Dependencies

```bash
npm install
```

This may take several minutes.

## Step 6: Configure Environment Variables

### 6.1 Create Production Environment File

```bash
cp .env.example .env.local
nano .env.local
```

### 6.2 Update Environment Variables

**IMPORTANT:** Update these values in `.env.local`:

```env
# API Configuration - Update with your actual API URL
NEXT_PUBLIC_API_BASE_URL=https://api.yourdomain.com/api/v1
NEXT_PUBLIC_API_URL=https://api.yourdomain.com/api/v1

# Application URLs - Update with your domain
NEXT_PUBLIC_APP_URL=https://yourdomain.com
NEXT_PUBLIC_SITE_URL=https://yourdomain.com

# Authentication Secret - Generate a secure random string
NEXTAUTH_URL=https://yourdomain.com
NEXTAUTH_SECRET=run-this-command-to-generate: openssl rand -base64 32

# Contact Emails
NEXT_PUBLIC_SUPPORT_EMAIL=support@yourdomain.com
NEXT_PUBLIC_CONTACT_EMAIL=contact@yourdomain.com
```

**Generate a secure NextAuth secret:**
```bash
openssl rand -base64 32
```

Copy the output and paste it as `NEXTAUTH_SECRET` value.

## Step 7: Build the Application

```bash
# Build for production
npm run build
```

This will create an optimized production build in the `.next` folder.

**Expected Output:**
```
Route (app)                              Size     First Load JS
┌ ○ /                                    5.2 kB         95.3 kB
├ ○ /about                               1.8 kB         88.9 kB
├ ○ /builder                             8.5 kB        102.6 kB
...
○  (Static)  prerendered as static HTML
```

## Step 8: Set Up Process Manager (PM2)

### 8.1 Install PM2

```bash
npm install -g pm2
```

### 8.2 Create PM2 Ecosystem File

```bash
nano ecosystem.config.js
```

Add the following content:

```javascript
module.exports = {
  apps: [{
    name: 'rigcheck-web',
    script: 'npm',
    args: 'start',
    cwd: '/var/www/html',  // Or ~/public_html for shared hosting
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    instances: 1,
    exec_mode: 'fork',
    max_memory_restart: '500M',
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
  }]
};
```

### 8.3 Create Logs Directory

```bash
mkdir -p logs
```

### 8.4 Start Application with PM2

```bash
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

**Copy and run the command that PM2 outputs** (it will contain sudo commands specific to your system).

### 8.5 Verify Application is Running

```bash
pm2 status
pm2 logs rigcheck-web
```

Your app should now be running on `localhost:3000`.

## Step 9: Configure Nginx as Reverse Proxy

### 9.1 Install Nginx (VPS only)

```bash
sudo apt install nginx -y
```

### 9.2 Create Nginx Configuration

```bash
sudo nano /etc/nginx/sites-available/rigcheck-web
```

Add the following configuration:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name yourdomain.com www.yourdomain.com;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Cache static assets
    location /_next/static {
        proxy_pass http://localhost:3000;
        proxy_cache_valid 200 60m;
        add_header Cache-Control "public, max-age=3600, immutable";
    }

    # Cache images
    location /_next/image {
        proxy_pass http://localhost:3000;
        proxy_cache_valid 200 24h;
    }
}
```

### 9.3 Enable Site

```bash
sudo ln -s /etc/nginx/sites-available/rigcheck-web /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 9.4 Configure Firewall

```bash
sudo ufw allow 'Nginx Full'
sudo ufw allow OpenSSH
sudo ufw enable
```

## Step 10: Set Up SSL Certificate (HTTPS)

### 10.1 Install Certbot

```bash
sudo apt install certbot python3-certbot-nginx -y
```

### 10.2 Obtain SSL Certificate

```bash
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

Follow the prompts:
- Enter your email address
- Agree to terms of service
- Choose whether to redirect HTTP to HTTPS (recommended: yes)

### 10.3 Verify Auto-Renewal

```bash
sudo certbot renew --dry-run
```

SSL certificates will auto-renew every 90 days.

## Step 11: Test Your Deployment

### 11.1 Visit Your Website

Open your browser and go to:
- `https://yourdomain.com`

### 11.2 Check SSL Certificate

Verify the SSL certificate is working properly:
```bash
curl -I https://yourdomain.com
```

Should return `HTTP/2 200` or `HTTP/1.1 200`.

### 11.3 Monitor Application Logs

```bash
pm2 logs rigcheck-web --lines 100
```

## Step 12: Set Up Automatic Deployment (Optional)

### 12.1 Create Deployment Script

```bash
nano ~/deploy-rigcheck.sh
```

Add:

```bash
#!/bin/bash
cd ~/public_html  # Or /var/www/html for VPS

echo "Pulling latest changes..."
git pull origin main

echo "Installing dependencies..."
npm install

echo "Building application..."
npm run build

echo "Restarting application..."
pm2 restart rigcheck-web

echo "Deployment complete!"
pm2 status
```

### 12.2 Make Script Executable

```bash
chmod +x ~/deploy-rigcheck.sh
```

### 12.3 Deploy Updates

Whenever you push changes to GitHub:

```bash
ssh u123456789@ssh.hostinger.com -p 65002
~/deploy-rigcheck.sh
```

### 12.4 Set Up GitHub Webhook (Advanced)

Create a webhook endpoint to auto-deploy on git push. This requires additional setup with webhook receivers.

## Troubleshooting

### Issue: Port 3000 Already in Use

```bash
# Find process using port 3000
lsof -i :3000

# Kill the process
kill -9 <PID>

# Or use a different port in ecosystem.config.js
```

### Issue: npm install Fails

```bash
# Clear npm cache
npm cache clean --force

# Remove node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Issue: Build Fails

```bash
# Check Node.js version (must be 18+)
node -v

# Check for build errors
npm run build 2>&1 | tee build.log
```

### Issue: PM2 Not Found

```bash
# Install PM2 locally
npm install pm2 -g

# Or use npx
npx pm2 start ecosystem.config.js
```

### Issue: 502 Bad Gateway

```bash
# Check if app is running
pm2 status

# Check Nginx configuration
sudo nginx -t

# Check Nginx error logs
sudo tail -f /var/log/nginx/error.log

# Restart services
pm2 restart rigcheck-web
sudo systemctl restart nginx
```

### Issue: Environment Variables Not Loading

```bash
# Verify .env.local exists
ls -la .env.local

# Check file permissions
chmod 600 .env.local

# Rebuild application
npm run build
pm2 restart rigcheck-web
```

## For Shared Hosting Without SSH

If your Hostinger plan doesn't support Node.js or SSH:

### Alternative: Static Export

1. **Build static version locally:**
   ```bash
   npm run build
   npm run export  # If configured
   ```

2. **Upload via FTP:**
   - Use FileZilla or Hostinger File Manager
   - Upload `out/` folder contents to `public_html/`

**Note:** This limits functionality (no server-side rendering, API routes won't work).

## Performance Optimization

### Enable Caching

Add to your Nginx config:
```nginx
location /_next/static/ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### Monitor Performance

```bash
# Check memory usage
pm2 monit

# View detailed metrics
pm2 describe rigcheck-web
```

### Set Up Log Rotation

```bash
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
```

## Security Checklist

- [ ] SSL certificate installed and working
- [ ] Environment variables secured (not in git)
- [ ] Firewall configured
- [ ] SSH key authentication enabled (disable password auth)
- [ ] Regular backups configured
- [ ] Rate limiting enabled (via Cloudflare or Nginx)
- [ ] Security headers configured in Nginx
- [ ] API CORS properly configured

## Backup Strategy

### Automated Backup Script

```bash
nano ~/backup-rigcheck.sh
```

```bash
#!/bin/bash
BACKUP_DIR=~/backups/rigcheck
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup application files
tar -czf $BACKUP_DIR/rigcheck-web-$DATE.tar.gz ~/public_html

# Keep only last 7 days
find $BACKUP_DIR -name "rigcheck-web-*.tar.gz" -mtime +7 -delete

echo "Backup completed: rigcheck-web-$DATE.tar.gz"
```

### Schedule Daily Backups

```bash
crontab -e
```

Add:
```cron
0 2 * * * ~/backup-rigcheck.sh
```

## Monitoring

### Check Application Status

```bash
pm2 status
pm2 logs rigcheck-web --lines 50
```

### Monitor Server Resources

```bash
htop  # or top
df -h  # disk usage
free -h  # memory usage
```

## Updating the Application

```bash
cd ~/public_html  # or /var/www/html

# Pull latest changes
git pull origin main

# Install new dependencies
npm install

# Rebuild
npm run build

# Restart
pm2 restart rigcheck-web

# Verify
pm2 logs rigcheck-web
```

## Support

**Hostinger Support:**
- Live Chat: Available 24/7 in hPanel
- Knowledge Base: https://support.hostinger.com
- Community Forum: https://www.hostinger.com/forum

**Next.js Documentation:**
- https://nextjs.org/docs/deployment

**PM2 Documentation:**
- https://pm2.keymetrics.io/docs

---

## Deployment Complete! 🚀

Your RigCheck website is now live on Hostinger!

**Quick Reference:**
- Website: https://yourdomain.com
- SSH: `ssh u123456789@ssh.hostinger.com -p 65002`
- Deploy: `~/deploy-rigcheck.sh`
- Logs: `pm2 logs rigcheck-web`
- Restart: `pm2 restart rigcheck-web`

**Next Steps:**
1. Test all website features
2. Set up your API backend (see API deployment guide)
3. Configure DNS for api.yourdomain.com
4. Set up monitoring and alerts
5. Configure CDN (Cloudflare recommended)
