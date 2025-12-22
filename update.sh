#!/bin/bash

# RigCheck Web - Update Script
# Run this script to deploy updates from Git

set -e  # Exit on any error

echo "================================"
echo "RigCheck Web Update Script"
echo "================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get current git branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo -e "${YELLOW}Current branch: $BRANCH${NC}"

# Check for uncommitted changes
if [[ -n $(git status -s) ]]; then
    echo -e "${YELLOW}Warning: You have uncommitted changes${NC}"
    git status -s
    echo ""
    echo "Continue anyway? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Update cancelled"
        exit 1
    fi
fi

echo ""
echo "Step 1: Pulling latest changes from Git..."
git pull origin "$BRANCH"

echo ""
echo "Step 2: Installing/updating dependencies..."
npm install

echo ""
echo "Step 3: Building application..."
npm run build

echo ""
echo "Step 4: Restarting application..."
pm2 restart rigcheck-web

echo ""
echo "Step 5: Checking application status..."
pm2 status

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Update Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Application has been updated and restarted"
echo ""
echo "View logs with: pm2 logs rigcheck-web"
echo ""
