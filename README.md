# RigCheck Web - Production-Ready for Hostinger

[![Next.js](https://img.shields.io/badge/Next.js-16.0-black)](https://nextjs.org/)
[![React](https://img.shields.io/badge/React-19.2-blue)](https://reactjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.x-blue)](https://www.typescriptlang.org/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind-4.x-38bdf8)](https://tailwindcss.com/)

## Overview

RigCheck is a comprehensive PC building platform that helps users:
- Build custom PC configurations with compatibility checking
- Compare components and prices
- Share builds with the community
- Get expert recommendations based on budget and use case
- Track wishlist and saved builds

This repository contains the Next.js web application for the RigCheck PC building platform.

## Features

✅ **PC Builder** - Interactive build creation with real-time compatibility checks
✅ **Component Database** - Extensive catalog of PC parts with specifications
✅ **Price Comparison** - Track prices from multiple retailers
✅ **Build Templates** - Pre-configured builds for different budgets
✅ **Social Features** - Share builds, comment, like, and follow users
✅ **Wishlist** - Save favorite components and builds
✅ **Comparison Tool** - Side-by-side component comparison
✅ **User Profiles** - Personal build galleries and social profiles
✅ **Admin Dashboard** - Manage users, builds, and content
✅ **Responsive Design** - Works on desktop, tablet, and mobile

## Tech Stack

- **Framework**: Next.js 16 (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS 4
- **UI Components**: Radix UI
- **Icons**: Lucide React
- **State Management**: React Context
- **Theme**: next-themes (dark mode support)
- **Notifications**: Sonner

## Quick Start

```bash
# Install dependencies
npm install

# Set up environment variables
cp .env.example .env.local
# Edit .env.local with your API URL

# Run development server
npm run dev
```

Visit `http://localhost:3000`

## Project Structure

```
rigcheck-web-deploy/
├── app/                    # Next.js App Router pages
│   ├── about/             # About page
│   ├── admin/             # Admin dashboard
│   ├── auth/              # Authentication pages
│   ├── builder/           # PC builder interface
│   ├── builds/            # Community builds
│   ├── compare/           # Component comparison
│   ├── components/        # Component catalog
│   ├── feed/              # Social feed
│   ├── profile/           # User profiles
│   ├── search/            # Search functionality
│   └── wishlist/          # Saved items
├── components/            # Reusable React components
│   ├── auth/              # Authentication components
│   ├── builder/           # Builder-specific components
│   ├── layout/            # Header, footer, nav
│   └── ui/                # UI primitives (buttons, cards, etc.)
├── lib/                   # Utility functions
│   ├── api.ts             # API client
│   ├── auth-context.tsx   # Authentication state
│   ├── build-templates.ts # Build presets
│   ├── currency.ts        # Currency formatting
│   └── utils.ts           # Helper functions
├── public/                # Static assets
│   └── demo-images/       # Component images
├── .env.example           # Environment variable template
├── .env.production        # Production config template
├── .gitignore             # Git ignore rules
├── deploy.sh              # Deployment script
├── update.sh              # Update script
├── backup.sh              # Backup script
└── package.json           # Dependencies
```

## Environment Variables

Copy `.env.example` to `.env.local` and configure:

```env
# API Configuration
NEXT_PUBLIC_API_BASE_URL=https://api.yourdomain.com/api/v1
NEXT_PUBLIC_SITE_URL=https://yourdomain.com

# Authentication
NEXTAUTH_SECRET=your-secret-here

# Contact
NEXT_PUBLIC_SUPPORT_EMAIL=support@yourdomain.com
```

## Local Development

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Start production server
npm start
```

Visit `http://localhost:3000`

## Deployment Scripts

### Initial Deployment
```bash
chmod +x deploy.sh
./deploy.sh
```

### Update Application
```bash
chmod +x update.sh
./update.sh
```

### Backup
```bash
chmod +x backup.sh
./backup.sh
```

## Building for Production

The application is pre-configured for optimal production builds:

- **Static Generation**: Pages are pre-rendered at build time
- **Code Splitting**: Automatic bundle optimization
- **Image Optimization**: Next.js Image component
- **Tree Shaking**: Unused code elimination
- **Minification**: JavaScript and CSS minification

Build output:
```
Route (app)               Size      First Load JS
┌ ○ /                    5.2 kB    95.3 kB
├ ○ /builder             8.5 kB    102.6 kB
├ ○ /components          6.1 kB    96.2 kB
...
```

## Deployment

### Vercel (Recommended)
1. Push code to GitHub
2. Import project in Vercel dashboard
3. Configure environment variables
4. Deploy!

### Manual Deployment
```bash
npm run build
# Upload .next folder to your hosting provider
```

## API Integration

The website connects to a Laravel API backend for:
- User authentication
- Component data
- Build storage
- Social features
- Admin operations

## Performance

The application is optimized for performance:

- **Lighthouse Score**: 95+ (target)
- **First Contentful Paint**: < 1.5s
- **Time to Interactive**: < 3.5s
- **Bundle Size**: Optimized with tree shaking
- **Image Loading**: Lazy loading + optimization
- **Caching**: Static page caching enabled

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- Mobile browsers (iOS Safari, Chrome Mobile)

## Security

- HTTPS enforced
- Secure headers configured
- XSS protection
- CSRF protection
- Environment variables secured
- API requests authenticated

## Monitoring

After deployment, monitor:
- Application status: `pm2 status`
- Application logs: `pm2 logs rigcheck-web`
- Error tracking: Set up Sentry (optional)
- Uptime monitoring: UptimeRobot (recommended)

## Troubleshooting

### Build Fails
```bash
# Clear cache and rebuild
rm -rf .next node_modules
npm install
npm run build
```

### Port Already in Use
```bash
# Check what's using port 3000
lsof -i :3000

# Kill the process
kill -9 <PID>
```

### Environment Variables Not Loading
```bash
# Rebuild after changing .env.local
npm run build
pm2 restart rigcheck-web
```

### 502 Bad Gateway
```bash
# Check application status
pm2 status

# Restart application
pm2 restart rigcheck-web

# Check Nginx config
sudo nginx -t
sudo systemctl restart nginx
```

## Updating the Application

To deploy updates:

```bash
# Pull latest changes
git pull origin main

# Run update script
./update.sh

# Or manually:
npm install
npm run build
pm2 restart rigcheck-web
```

## Contributing

This is a production deployment repository. Development happens in the main repository.

## Support

For issues and questions, please open a GitHub issue.

## License

This project is for educational purposes.

---

**Built with ❤️ for the PC building community**
