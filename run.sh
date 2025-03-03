#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo -e "${BLUE}Ignition Docker Compose Setup Helper${NC}"
    echo
    echo "Usage: $0 [command] [options]"
    echo
    echo "Commands:"
    echo "  standard       Start standard gateway with database"
    echo "  scaleout       Start scale-out architecture (frontend/backend)"
    echo "  hubspoke       Start hub-and-spoke architecture"
    echo "  down           Stop and remove all containers"
    echo "  clean          Stop containers and remove volumes"
    echo
    echo "Options:"
    echo "  --edge         Configure spokes as edge edition (for hubspoke only)"
    echo "  --standard     Configure spokes as standard edition (for hubspoke only)"
    echo
    echo "Examples:"
    echo "  $0 standard            # Start standard gateway"
    echo "  $0 scaleout            # Start scale-out architecture"
    echo "  $0 hubspoke --edge     # Start hub-and-spoke with edge edition spokes"
    echo "  $0 down                # Stop all containers"
    echo
}

# Make sure we have the .env file
if [ ! -f .env ]; then
    echo -e "${BLUE}First-time setup: Creating .env file from template...${NC}"
    cp .env.example .env
    echo -e "${GREEN}Created .env file. Please review and modify as needed.${NC}"
fi

# Create necessary directories if they don't exist
mkdir -p db-init

# Process command
case "$1" in
    standard)
        echo -e "${BLUE}Starting standard Ignition gateway...${NC}"
        docker-compose --profile standard up -d
        echo -e "${GREEN}Standard gateway started!${NC}"
        echo "Access at: http://${GATEWAY_NAME:-ignition-gateway}.localtest.me"
        ;;
    
    scaleout)
        echo -e "${BLUE}Starting scale-out architecture...${NC}"
        docker-compose --profile scaleout up -d
        echo -e "${GREEN}Scale-out architecture started!${NC}"
        echo "Frontend: http://${FRONTEND_NAME:-ignition-frontend}.localtest.me"
        echo "Backend: http://${BACKEND_NAME:-ignition-backend}.localtest.me"
        ;;
    
    hubspoke)
        # Check for edition option
        if [ "$2" == "--edge" ]; then
            sed -i 's/SPOKE_EDITION=.*/SPOKE_EDITION=edge/g' .env
            sed -i 's/SPOKE_MODULES=.*/SPOKE_MODULES=perspective,tag-historian,web-developer,opc-ua/g' .env
            echo -e "${BLUE}Configuring spokes as edge edition...${NC}"
        elif [ "$2" == "--standard" ]; then
            sed -i 's/SPOKE_EDITION=.*/SPOKE_EDITION=standard/g' .env
            sed -i 's/SPOKE_MODULES=.*/SPOKE_MODULES=perspective,tag-historian,web-developer,opc-ua,reporting,alarm-notification,sql-bridge,vision,voice-notification/g' .env
            echo -e "${BLUE}Configuring spokes as standard edition...${NC}"
        fi
        
        echo -e "${BLUE}Starting hub-and-spoke architecture...${NC}"
        docker-compose --profile hubspoke up -d
        echo -e "${GREEN}Hub-and-spoke architecture started!${NC}"
        echo "Hub: http://${HUB_NAME:-ignition-hub}.localtest.me"
        echo "Spoke 1: http://${SPOKE1_NAME:-ignition-spoke1}.localtest.me"
        echo "Spoke 2: http://${SPOKE2_NAME:-ignition-spoke2}.localtest.me"
        echo "Spoke 3: http://${SPOKE3_NAME:-ignition-spoke3}.localtest.me"
        ;;
    
    down)
        echo -e "${BLUE}Stopping all containers...${NC}"
        docker-compose down
        echo -e "${GREEN}All containers stopped.${NC}"
        ;;
    
    clean)
        echo -e "${RED}Warning: This will remove all containers and volumes!${NC}"
        read -p "Are you sure you want to continue? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Stopping containers and removing volumes...${NC}"
            docker-compose down -v
            echo -e "${GREEN}Cleanup complete.${NC}"
        fi
        ;;
    
    *)
        usage
        exit 1
        ;;
esac

exit 0