#!/bin/bash
# restore.sh - PostgreSQL restore script for n8n

set -e

# Configuration
CONTAINER_NAME="postgres"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "════════════════════════════════════════════════════"
echo "  n8n PostgreSQL Restore"
echo "════════════════════════════════════════════════════"
echo ""

# Check if backup file is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: No backup file specified${NC}"
    echo ""
    echo "Usage: $0 <backup_file>"
    echo ""
    echo "Available backups:"
    ls -lh ./backups/ 2>/dev/null || echo "  No backups found"
    exit 1
fi

BACKUP_FILE="$1"

# Check if backup file exists
if [ ! -f "${BACKUP_FILE}" ]; then
    echo -e "${RED}Error: Backup file '${BACKUP_FILE}' not found${NC}"
    exit 1
fi

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

echo -e "${YELLOW}⚠️  WARNING: This will replace the current database!${NC}"
echo ""
echo "Database: ${POSTGRES_DB}"
echo "Backup: ${BACKUP_FILE}"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "${confirm}" != "yes" ]; then
    echo "Restore cancelled"
    exit 0
fi

echo ""
echo -e "${YELLOW}Decompressing backup if needed...${NC}"

# Decompress if .gz
if [[ "${BACKUP_FILE}" == *.gz ]]; then
    TEMP_FILE="${BACKUP_FILE%.gz}"
    gunzip -c "${BACKUP_FILE}" > "${TEMP_FILE}"
    RESTORE_FILE="${TEMP_FILE}"
else
    RESTORE_FILE="${BACKUP_FILE}"
fi

echo -e "${YELLOW}Restoring database...${NC}"

# Restore
docker exec -i "${CONTAINER_NAME}" psql -U "${POSTGRES_USER}" < "${RESTORE_FILE}"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Database restored successfully!${NC}"
    
    # Clean up temp file
    if [ "${RESTORE_FILE}" != "${BACKUP_FILE}" ]; then
        rm "${RESTORE_FILE}"
    fi
else
    echo ""
    echo -e "${RED}✗ Restore failed!${NC}"
    exit 1
fi

echo ""
echo "════════════════════════════════════════════════════"
echo -e "${GREEN}Restore completed successfully!${NC}"
echo "════════════════════════════════════════════════════"
echo ""
echo "You may need to restart n8n:"
echo "  docker-compose restart n8n"






















