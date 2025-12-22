# Deploy RigCheck Website to Vercel (FREE)

## Why Vercel?
- **FREE** for Next.js projects
- Automatic deployments from GitHub
- Perfect for Next.js (made by the same team)
- Global CDN, SSL included
- No server management

## Step 1: Push to GitHub

```powershell
cd "c:\Users\khand\Music\pc-part-dataset-main\rigcheck-web"

# Initialize and push
git init
git add .
git commit -m "Initial commit for Vercel deployment"
git branch -M main
git remote add origin https://github.com/echo-anik/rigcheck-web.git
git push -u origin main
```

## Step 2: Deploy to Vercel

1. Go to: https://vercel.com
2. Click **Sign Up** or **Log In** (use GitHub account)
3. Click **Add New** → **Project**
4. **Import** your GitHub repo: `echo-anik/rigcheck-web`
5. Configure project:
   - **Framework Preset**: Next.js (auto-detected)
   - **Root Directory**: `./` (leave default)
   - **Build Command**: `npm run build` (auto-filled)
   - **Output Directory**: `.next` (auto-filled)

6. **Environment Variables** - Add these:
   ```
   NEXT_PUBLIC_API_BASE_URL=https://yellow-dinosaur-111977.hostingersite.com/api/v1
   NEXT_PUBLIC_SITE_URL=https://your-vercel-domain.vercel.app
   NEXT_PUBLIC_SITE_NAME=RigCheck
   ```

7. Click **Deploy**

## Step 3: Wait 2-3 Minutes

Vercel will:
- Install dependencies
- Build your Next.js app
- Deploy to global CDN
- Give you a URL like: `rigcheck-web.vercel.app`

## Step 4: Update API CORS

Your Laravel API needs to allow requests from Vercel domain.

**SSH to Hostinger:**
```bash
ssh u713301745@ssh.hostinger.com -p 65002
cd ~/domains/yellow-dinosaur-111977.hostingersite.com/public_html
nano config/cors.php
```

Add your Vercel domain to allowed origins:
```php
'allowed_origins' => [
    'https://rigcheck-web.vercel.app',
    'https://your-custom-domain.com',
],
```

## Step 5: Custom Domain (Optional)

In Vercel dashboard:
1. Go to your project → **Settings** → **Domains**
2. Add your custom domain
3. Update DNS records as instructed by Vercel

## Updates (Automatic!)

Just push to GitHub:
```powershell
cd "c:\Users\khand\Music\pc-part-dataset-main\rigcheck-web"
git add .
git commit -m "Update website"
git push
```

Vercel automatically rebuilds and deploys!

## That's It!

- Website: Your Vercel URL
- API: https://yellow-dinosaur-111977.hostingersite.com
- Cost: $0 (FREE)
- Deployment time: 2-3 minutes
- Updates: Automatic on git push

## Troubleshooting

**Build fails?**
- Check build logs in Vercel dashboard
- Verify environment variables are set

**API not connecting?**
- Check CORS settings in Laravel
- Verify API URL in environment variables
- Check browser console for errors

**Need help?**
- Vercel docs: https://vercel.com/docs
- Next.js docs: https://nextjs.org/docs
