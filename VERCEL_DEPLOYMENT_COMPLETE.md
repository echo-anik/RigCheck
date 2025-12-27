# RigCheck Website - Complete Vercel Deployment Guide

**Your Live API:** https://yellow-dinosaur-111977.hostingersite.com/api/v1 ✅
**Status:** Ready to Deploy to Vercel!

---

## 🚀 Quick Deploy to Vercel (5 Minutes)

### Option 1: Deploy from GitHub (Recommended)

#### Step 1: Push to GitHub

```powershell
cd "C:\Users\khand\Music\pc-part-dataset-main\rigcheck-web"

# Check git status
git status

# If already initialized, just add and commit
git add .
git commit -m "Update for Vercel deployment with live API"
git push
```

#### Step 2: Deploy to Vercel

1. **Go to** https://vercel.com/new
2. **Sign in** with GitHub
3. **Import** your repository: `echo-anik/rigcheck-web`
4. **Configure:**
   - Framework: Next.js (auto-detected)
   - Root Directory: `./`
   - Build Command: `npm run build`
   - Output Directory: `.next`

5. **Environment Variables** (Already in vercel.json, but you can override):
   ```
   NEXT_PUBLIC_API_BASE_URL=https://yellow-dinosaur-111977.hostingersite.com/api/v1
   NEXT_PUBLIC_API_URL=https://yellow-dinosaur-111977.hostingersite.com/api/v1
   NEXT_PUBLIC_SITE_NAME=RigCheck PC Builder
   ```

6. **Click Deploy** 🚀

---

### Option 2: Deploy using Vercel CLI

```powershell
# Install Vercel CLI globally
npm install -g vercel

# Login to Vercel
vercel login

# Deploy (run from rigcheck-web directory)
cd "C:\Users\khand\Music\pc-part-dataset-main\rigcheck-web"
vercel --prod
```

Follow the prompts and you're done!

---

## ⚙️ What's Already Configured

### ✅ API Connection
- **Live API URL:** `https://yellow-dinosaur-111977.hostingersite.com/api/v1`
- **All endpoints ready:**
  - `/components` - Browse PC parts
  - `/login` - User authentication
  - `/register` - New user signup
  - `/builds/public` - Community builds
  - `/admin/*` - Admin panel (requires login)

### ✅ Environment Variables
- Production `.env.production` updated
- `vercel.json` configured
- Currency: BDT (Bangladeshi Taka)
- Locale: en-BD

### ✅ Build Configuration
- Next.js 16 with React 19
- Tailwind CSS 4
- TypeScript
- Optimized for production

---

## 🔧 Post-Deployment Steps

### Step 1: Update CORS on API

After Vercel gives you a URL (e.g., `rigcheck-web.vercel.app`), update the API CORS:

**SSH to Hostinger:**
```bash
ssh u713301745@ssh.hostinger.com -p 65002
cd ~/domains/yellow-dinosaur-111977.hostingersite.com/laravel-app
nano config/cors.php
```

**Update allowed origins:**
```php
'allowed_origins' => [
    'https://rigcheck-web.vercel.app',
    'https://*.vercel.app', // Allow all Vercel preview deployments
],
```

**Save and cache:**
```bash
php artisan config:cache
```

### Step 2: Update Environment Variables in Vercel

After deployment, update these in **Vercel Dashboard → Settings → Environment Variables**:

```
NEXT_PUBLIC_APP_URL=https://your-actual-vercel-url.vercel.app
NEXT_PUBLIC_SITE_URL=https://your-actual-vercel-url.vercel.app
NEXTAUTH_URL=https://your-actual-vercel-url.vercel.app
```

Then **Redeploy** from Vercel dashboard.

---

## 🧪 Test Your Website

Once deployed, test these pages:

### Public Pages
- `https://your-vercel-url.vercel.app/` - Homepage
- `/components` - Browse components
- `/builds` - Community builds
- `/build` - PC Builder tool

### Test API Connection
Open browser console (F12) and check:
- Network tab should show requests to `yellow-dinosaur-111977.hostingersite.com`
- No CORS errors
- Components load successfully

### Test Features
1. **Browse Components** - Should show CPU, GPU, RAM, etc.
2. **Build PC** - Should allow selecting parts
3. **Login** - Test with admin credentials:
   ```
   Email: admin@rigcheck.com
   Password: Admin@123456
   ```
4. **Admin Panel** - Should show dashboard with stats

---

## 🎨 Custom Domain (Optional)

### Add Your Custom Domain

1. **In Vercel Dashboard:**
   - Go to **Settings** → **Domains**
   - Add `yourdomain.com`
   - Follow DNS instructions

2. **Update Environment Variables:**
   ```
   NEXT_PUBLIC_APP_URL=https://yourdomain.com
   NEXT_PUBLIC_SITE_URL=https://yourdomain.com
   NEXTAUTH_URL=https://yourdomain.com
   ```

3. **Update API CORS:**
   Add `yourdomain.com` to allowed origins in `config/cors.php`

---

## 🔄 Automatic Deployments

Every time you push to GitHub, Vercel will:
- ✅ Automatically build
- ✅ Run tests
- ✅ Deploy to production
- ✅ Update global CDN

```powershell
# Make changes
# ...

# Deploy
git add .
git commit -m "Update website"
git push

# Vercel deploys automatically!
```

---

## 📊 Project Structure

```
rigcheck-web/
├── app/                    # Next.js 13+ app directory
│   ├── (auth)/            # Authentication pages
│   ├── (dashboard)/       # User dashboard
│   ├── admin/             # Admin panel
│   ├── build/             # PC builder
│   ├── builds/            # Community builds
│   ├── components/        # Component pages
│   └── layout.tsx         # Root layout
├── components/            # Reusable React components
├── lib/                   # Utilities and helpers
├── public/                # Static assets
├── .env.production        # Production env (updated)
├── vercel.json           # Vercel config (created)
└── package.json          # Dependencies

```

---

## 🐛 Troubleshooting

### Build Fails on Vercel

**Check build logs:**
1. Go to Vercel dashboard
2. Click on failed deployment
3. View build logs

**Common fixes:**
- Missing environment variables → Add in Vercel settings
- Build timeout → Contact Vercel support (rare)
- Dependency issues → Clear build cache and redeploy

### API Not Connecting

**Checklist:**
- [ ] API is running (test: `curl https://yellow-dinosaur-111977.hostingersite.com/api/v1/components`)
- [ ] CORS configured on API for Vercel domain
- [ ] Environment variables set correctly in Vercel
- [ ] No typos in API URL

**Test API:**
```bash
# From terminal
curl https://yellow-dinosaur-111977.hostingersite.com/api/v1/components
```

Should return JSON with components.

**Check browser console:**
- F12 → Console tab
- Look for CORS errors
- Check Network tab for failed requests

### Images Not Loading

**Vercel Image Optimization:**
Next.js Image component works automatically on Vercel.

If using external images, add to `next.config.ts`:
```typescript
images: {
  domains: ['yellow-dinosaur-111977.hostingersite.com'],
}
```

---

## 💡 Performance Tips

### Vercel automatically provides:
- ✅ Global CDN (100+ locations)
- ✅ Edge functions
- ✅ Image optimization
- ✅ Automatic SSL/HTTPS
- ✅ DDoS protection
- ✅ Analytics (optional)

### Enable Vercel Analytics (Free):
1. Go to project settings
2. Enable **Vercel Analytics**
3. See real user metrics!

---

## 📈 What You Get (FREE Tier)

**Vercel Free Tier Includes:**
- ✅ Unlimited deployments
- ✅ 100 GB bandwidth/month
- ✅ Automatic HTTPS
- ✅ Global CDN
- ✅ Preview deployments
- ✅ Analytics
- ✅ 6,000 build minutes/month

**Perfect for this project!** 🎉

---

## ✅ Deployment Checklist

- [ ] Code pushed to GitHub
- [ ] Vercel account created
- [ ] Repository imported to Vercel
- [ ] Environment variables configured
- [ ] First deployment successful
- [ ] API connection tested
- [ ] CORS configured on API
- [ ] Components loading correctly
- [ ] Login/Register working
- [ ] Admin panel accessible
- [ ] Custom domain added (optional)

---

## 🎯 Expected URLs

After deployment:

**Website:** `https://rigcheck-web.vercel.app` (or your custom domain)
**API:** `https://yellow-dinosaur-111977.hostingersite.com/api/v1`

**Test these endpoints:**
- Website: `/`
- Components: `/components`
- Build PC: `/build`
- Login: `/login`
- Admin: `/admin` (requires login)

---

## 🎉 Success Indicators

Your deployment is successful when:

✅ Website loads at your Vercel URL
✅ Components page shows PC parts with prices in BDT
✅ PC Builder tool allows selecting components
✅ Login works with admin credentials
✅ Admin dashboard shows statistics
✅ No console errors
✅ API requests complete successfully

---

## 📞 Need Help?

**Vercel Issues:**
- Docs: https://vercel.com/docs
- Support: https://vercel.com/support

**API Issues:**
- Check Laravel logs: `tail -f ~/domains/yellow-dinosaur-111977.hostingersite.com/laravel-app/storage/logs/laravel.log`
- Test API: `curl https://yellow-dinosaur-111977.hostingersite.com/api/v1/components`

---

**Your website is ready to deploy!** 🚀

👉 **Next Step:** Push to GitHub and deploy to Vercel (takes 2-3 minutes)
