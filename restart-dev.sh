#!/bin/bash

# Stop and remove containers
docker compose -f docker-compose.dev.yml --env-file .env down

# Remove old image
docker rmi ghcr.io/oeun-nuphea/note-api:latest

# Rebuild and start containers in detached mode
docker compose -f docker-compose.dev.yml --env-file .env up -d --build


