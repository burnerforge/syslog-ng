#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🚀 SentinelOne Rootless Syslog-NG Setup${NC}"
echo "========================================"
echo ""
echo "This script sets up the high-performance, single-container Rootless Syslog-NG solution."
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed.${NC}"
    echo "Please install Docker before proceeding: https://docs.docker.com/engine/install/"
    exit 1
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null && ! docker-compose --version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not available.${NC}"
    echo "Please install Docker Compose before proceeding: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}✅ Docker and Docker Compose are available${NC}"
echo ""

echo -e "${GREEN}⚡ Setting up Rootless Syslog-NG...${NC}"
echo "This solution provides high-performance, security-focused log collection."
if [ -d "rootless-syslog-ng" ]; then
    cd rootless-syslog-ng || exit 1
    if [ -f "setup.sh" ]; then
        chmod +x setup.sh
        ./setup.sh
    else
        echo -e "${YELLOW}Setup script not found. Please see rootless-syslog-ng/README.md for manual setup.${NC}"
    fi
else
    echo -e "${RED}❌ Rootless syslog-ng directory not found.${NC}"
fi

echo ""
echo -e "${CYAN}📚 Need help?${NC}"
echo "  - Check rootless-syslog-ng/README.md for detailed instructions"
echo "  - Review shared/samples/ for test log files"
echo "  - Visit shared/docs/ for architecture information"
