# Ignition Docker Compose Setup

This repository contains a configurable Docker Compose setup for running Ignition SCADA in various architectures:

1. **Standard Gateway** - A standalone Ignition gateway with a PostgreSQL database
2. **Scale-out Architecture** - Frontend and backend gateways with a shared database
3. **Hub-and-Spoke Architecture** - A hub gateway with three spoke gateways (configurable as standard or edge edition)
4. **IIoT Architecture** - A setup with a central Ignition gateway (Distributor + Engine modules) and edge gateways (Transmission module)

## Prerequisites

- Docker and Docker Compose installed
- Traefik reverse proxy running in your environment (with a network named 'proxy')
- Basic knowledge of Ignition SCADA

## Directory Structure

The repository is organized as follows:

```text
├── db-init/              # Database initialization scripts (optional)
├── gw-init/              # Gateway backup files (.gwbk) for automatic restoration
│   ├── ignition-gateway.gwbk
│   ├── ignition-frontend.gwbk
│   ├── ignition-backend.gwbk
│   ├── ignition-hub.gwbk
│   ├── ignition-spoke1.gwbk
│   ├── ignition-spoke2.gwbk
│   ├── ignition-spoke3.gwbk
│   ├── ignition-mqtt-central.gwbk
│   ├── ignition-mqtt-edge1.gwbk
│   └── ignition-mqtt-edge2.gwbk
├── gw-modules/           # Cirrus Link MQTT modules
│   ├── MQTT-Distributor-signed.modl
│   ├── MQTT-Engine-signed.modl
│   └── MQTT-Transmission-signed.modl

├── docker-compose.yml    # Main configuration file
├── run.sh                # Helper script for managing the setup
└── .env                  # Environment variables (created from .env.example)
```

## Configuration

1. Copy the .env.example file to .env and modify as needed:

   ```bash
   cp .env.example .env
   ```

2. Edit the .env file to configure your environment.

## Gateway Backup Restoration

This setup supports automatic restoration of gateway backups on startup:

1. Place your Ignition gateway backup files (.gwbk) in the `gw-init/` directory
2. Make sure the filenames match the gateway names as shown in the directory structure
3. The system will automatically restore the backups when the containers start

## Running the Different Configurations

### Using the Helper Script

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

# Start IIoT architecture
./run.sh iiot

### IIoT Architecture
- MQTT Central Gateway: http://ignition-mqtt-central.localtest.me
- MQTT Edge Gateway 1: http://ignition-mqtt-edge1.localtest.me
- MQTT Edge Gateway 2: http://ignition-mqtt-edge2.localtest.me

# Stop all containers
./run.sh down

# Clean up volumes and containers
./run.sh clean
```

### Manual Docker Compose Commands

Alternatively, you can use Docker Compose directly:

#### Standard Gateway

```bash
docker compose --profile standard up -d
```

#### Scale-out Architecture

```bash
docker compose --profile scaleout up -d
```

#### Hub-and-Spoke Architecture

```bash
docker compose --profile hubspoke up -d
```

## Service Access

All services are accessible via Traefik using the localtest.me domain (or your custom domain if configured):

### Standard Gateway

- Gateway: <http://ignition-gateway.localtest.me>

### Scale-out Architecture

- Frontend: <http://ignition-frontend.localtest.me>
- Backend: <http://ignition-backend.localtest.me>

### Hub-and-Spoke Architecture

- Hub: <http://ignition-hub.localtest.me>
- Spoke 1: <http://ignition-spoke1.localtest.me>
- Spoke 2: <http://ignition-spoke2.localtest.me>
- Spoke 3: <http://ignition-spoke3.localtest.me>

## Configuring Spoke Edition

To set the spoke gateways to edge edition, update these variables in your .env file:

```yaml
SPOKE_EDITION=edge
SPOKE_MODULES=perspective,tag-historian,web-developer,opc-ua
```

To use standard edition spokes:

```yaml
SPOKE_EDITION=standard
SPOKE_MODULES=perspective,tag-historian,web-developer,opc-ua,reporting,alarm-notification,sql-bridge,vision,voice-notification
```

## Gateway Network Configuration

This setup automatically configures Gateway Network connections:

- In the scale-out architecture, the frontend connects to the backend
- In the hub-and-spoke architecture, all spokes connect to the hub

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
