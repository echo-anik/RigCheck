#!/bin/bash

# RigCheck Web - Backup Script
# Creates a backup of the application

set -e

echo "================================"
echo "RigCheck Web Backup Script"
echo "================================"
echo ""

# Configuration
BACKUP_DIR=~/backups/rigcheck-web
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="rigcheck-web-$DATE.tar.gz"
APP_DIR=$(pwd)

echo "Creating backup directory..."
mkdir -p "$BACKUP_DIR"

echo ""
echo "Creating backup: $BACKUP_NAME"
echo "This may take a few minutes..."

# Create backup (exclude node_modules, .next, logs)
tar -czf "$BACKUP_DIR/$BACKUP_NAME" \
    --exclude='node_modules' \
    --exclude='.next' \
    --exclude='logs' \
    --exclude='.git' \
    -C "$(dirname "$APP_DIR")" "$(basename "$APP_DIR")"

# Get backup size
BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_NAME" | cut -f1)

echo ""
echo "✓ Backup created successfully!"
echo "  Location: $BACKUP_DIR/$BACKUP_NAME"
echo "  Size: $BACKUP_SIZE"

# Clean up old backups (keep last 7 days)
echo ""
echo "Cleaning up old backups (keeping last 7 days)..."
find "$BACKUP_DIR" -name "rigcheck-web-*.tar.gz" -mtime +7 -delete

# List remaining backups
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/rigcheck-web-*.tar.gz 2>/dev/null | wc -l)
echo "Total backups: $BACKUP_COUNT"

echo ""
echo "================================"
echo "Backup Complete!"
echo "================================"
echo ""
echo "To restore from backup:"
echo "  tar -xzf $BACKUP_DIR/$BACKUP_NAME -C ~/"
echo ""
