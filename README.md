# Ignition Docker Compose Setup

This repository contains a configurable Docker Compose setup for running Ignition SCADA in various architectures:

1. **Standard Gateway** - A standalone Ignition gateway with a PostgreSQL database
2. **Scale-out Architecture** - Frontend and backend gateways with a shared database
3. **Hub-and-Spoke Architecture** - A hub gateway with three spoke gateways (configurable as standard or edge edition)

## Prerequisites

- Docker and Docker Compose installed
- Traefik reverse proxy running in your environment (with a network named 'traefik_network')
- Basic knowledge of Ignition SCADA

## Directory Structure

Before running, create the following directory:

```
├── db-init/              # Database initialization scripts (optional)
```

## Configuration

1. Copy the .env.example file to .env and modify as needed:
   ```
   cp .env.example .env
   ```

2. Edit the .env file to configure your environment.

## Running the Different Configurations

### Standard Gateway

```bash
docker-compose --profile standard up -d
```

This will start:
- A PostgreSQL database
- A single Ignition gateway (standard edition)

### Scale-out Architecture

```bash
docker-compose --profile scaleout up -d
```

This will start:
- A PostgreSQL database
- A frontend Ignition gateway 
- A backend Ignition gateway

### Hub-and-Spoke Architecture

```bash
docker-compose --profile hubspoke up -d
```

This will start:
- A PostgreSQL database
- A hub Ignition gateway
- Three spoke Ignition gateways (configurable as standard or edge edition)

## Service Access

All services are accessible via Traefik using the localtest.me domain (or your custom domain if configured):

### Standard Gateway
- Gateway: http://ignition-gateway.localtest.me

### Scale-out Architecture
- Frontend: http://ignition-frontend.localtest.me
- Backend: http://ignition-backend.localtest.me

### Hub-and-Spoke Architecture
- Hub: http://ignition-hub.localtest.me
- Spoke 1: http://ignition-spoke1.localtest.me
- Spoke 2: http://ignition-spoke2.localtest.me
- Spoke 3: http://ignition-spoke3.localtest.me

## Configuring Spoke Edition

To set the spoke gateways to edge edition, update these variables in your .env file:

```
SPOKE_EDITION=edge
SPOKE_MODULES=perspective,tag-historian,web-developer,opc-ua
```

To use standard edition spokes:

```
SPOKE_EDITION=standard
SPOKE_MODULES=perspective,tag-historian,web-developer,opc-ua,reporting,alarm-notification,sql-bridge,vision,voice-notification
```

## Helper Script

A helper script `run.sh` is provided to make it easier to manage the different configurations:

```bash
# Start standard gateway
./run.sh standard

# Start scale-out architecture
./run.sh scaleout

# Start hub-and-spoke with edge edition spokes
./run.sh hubspoke --edge

# Start hub-and-spoke with standard edition spokes
./run.sh hubspoke --standard

# Stop all containers
./run.sh down

# Clean up volumes and containers
./run.sh clean
```

## Additional Customization

For more advanced customizations, you can create Docker Compose override files:

1. Create a `docker-compose.override.yml` file for local development changes
2. Create environment-specific files like `docker-compose.prod.yml`

Example override:

```yaml
services:
  db:
    ports:
      - "5432:5432"  # Expose database port
  
  gateway:
    environment:
      CUSTOM_VAR: "custom-value"
```

## Gateway Network Configuration

This setup automatically configures Gateway Network connections:

- In the scale-out architecture, the frontend connects to the backend
- In the hub-and-spoke architecture, all spokes connect to the hub