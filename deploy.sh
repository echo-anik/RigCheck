#!/bin/bash

# RigCheck Web - Deployment Script for Hostinger
# This script handles the initial deployment setup

set -e  # Exit on any error

echo "================================"
echo "RigCheck Web Deployment Script"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js is not installed${NC}"
    echo "Please install Node.js 18.x or higher first"
    echo "Run: curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt install -y nodejs"
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d 'v' -f 2 | cut -d '.' -f 1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo -e "${RED}Error: Node.js version must be 18 or higher${NC}"
    echo "Current version: $(node -v)"
    exit 1
fi

echo -e "${GREEN}✓ Node.js $(node -v) detected${NC}"

# Check if .env.local exists
if [ ! -f .env.local ]; then
    echo -e "${YELLOW}Warning: .env.local not found${NC}"
    echo "Creating from .env.example..."
    cp .env.example .env.local
    echo -e "${RED}IMPORTANT: Edit .env.local with your production values before continuing!${NC}"
    echo "Press Ctrl+C to cancel, or Enter to continue..."
    read
fi

echo ""
echo "Step 1: Installing dependencies..."
npm install

echo ""
echo "Step 2: Building application..."
npm run build

# Check if PM2 is installed
if ! command -v pm2 &> /dev/null; then
    echo ""
    echo "Step 3: Installing PM2..."
    npm install -g pm2
fi

echo ""
echo "Step 4: Creating ecosystem config..."
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'rigcheck-web',
    script: 'npm',
    args: 'start',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    instances: 1,
    exec_mode: 'fork',
    max_memory_restart: '500M',
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    autorestart: true,
    watch: false
  }]
};
EOF

echo ""
echo "Step 5: Creating logs directory..."
mkdir -p logs

echo ""
echo "Step 6: Starting application with PM2..."
pm2 start ecosystem.config.js
pm2 save

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Your application is now running!"
echo ""
echo "Useful commands:"
echo "  pm2 status              - Check application status"
echo "  pm2 logs rigcheck-web   - View application logs"
echo "  pm2 restart rigcheck-web - Restart application"
echo "  pm2 stop rigcheck-web   - Stop application"
echo ""
echo "Next steps:"
echo "1. Set up Nginx as reverse proxy (see HOSTINGER_DEPLOYMENT.md)"
echo "2. Configure SSL certificate with Certbot"
echo "3. Test your website at http://localhost:3000"
echo ""
echo "For detailed instructions, see HOSTINGER_DEPLOYMENT.md"
echo ""
