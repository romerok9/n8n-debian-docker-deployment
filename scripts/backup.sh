#!/bin/bash
# backup.sh - PostgreSQL backup script for n8n

set -e

# Configuration
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/n8n_backup_${TIMESTAMP}.sql"
CONTAINER_NAME="postgres"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "════════════════════════════════════════════════════"
echo "  n8n PostgreSQL Backup"
echo "════════════════════════════════════════════════════"
echo ""

# Create backup directory
mkdir -p "${BACKUP_DIR}"

# Check if container is running
if ! docker ps | grep -q "${CONTAINER_NAME}"; then
    echo -e "${RED}Error: PostgreSQL container '${CONTAINER_NAME}' is not running${NC}"
    exit 1
fi

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo -e "${RED}Error: .env file not found${NC}"
    exit 1
fi

echo -e "${YELLOW}Creating backup...${NC}"
echo "Database: ${POSTGRES_DB}"
echo "Output: ${BACKUP_FILE}"
echo ""

# Create backup
docker exec -t "${CONTAINER_NAME}" pg_dumpall -c -U "${POSTGRES_USER}" > "${BACKUP_FILE}"

if [ $? -eq 0 ]; then
    BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
    echo -e "${GREEN}✓ Backup created successfully!${NC}"
    echo ""
    echo "File: ${BACKUP_FILE}"
    echo "Size: ${BACKUP_SIZE}"
    echo ""
    
    # Compress backup
    echo -e "${YELLOW}Compressing backup...${NC}"
    gzip "${BACKUP_FILE}"
    COMPRESSED_SIZE=$(du -h "${BACKUP_FILE}.gz" | cut -f1)
    echo -e "${GREEN}✓ Backup compressed${NC}"
    echo "File: ${BACKUP_FILE}.gz"
    echo "Size: ${COMPRESSED_SIZE}"
    echo ""
    
    # List recent backups
    echo "Recent backups:"
    ls -lh "${BACKUP_DIR}" | tail -5
else
    echo -e "${RED}✗ Backup failed!${NC}"
    exit 1
fi

echo ""
echo "════════════════════════════════════════════════════"
echo -e "${GREEN}Backup completed successfully!${NC}"
echo "════════════════════════════════════════════════════"

