#!/bin/bash
# build-images.sh — build and push all Docker images to Docker Hub
set -euo pipefail

DOCKER_USER="killux3k"

# Versions
INVENTORY_DB_TAG="1.0.0"
BILLING_DB_TAG="1.0.0"
BILLING_QUEUE_TAG="1.0.0"
INVENTORY_APP_TAG="1.0.0"
BILLING_APP_TAG="1.0.0"
API_GATEWAY_TAG="1.0.0"

log() { echo -e "\033[0;32m[+]\033[0m $*"; }

build_and_push() {
    local name="$1"
    local tag="$2"
    local path="$3"
    
    log "Building $name:$tag from $path..."
    docker build -t "${DOCKER_USER}/${name}:${tag}" "$path"
    
    log "Pushing ${DOCKER_USER}/${name}:${tag}..."
    docker push "${DOCKER_USER}/${name}:${tag}"
}

# Adjust paths to where YOUR Dockerfiles live
build_and_push "inventory-db"    "$INVENTORY_DB_TAG"    "./srcs/postgres-db"
build_and_push "billing-db"      "$BILLING_DB_TAG"      "./srcs/postgres-db"
build_and_push "billing-queue"   "$BILLING_QUEUE_TAG"   "./srcs/rabbitmq"
build_and_push "inventory-app"   "$INVENTORY_APP_TAG"   "./srcs/inventory-app"
build_and_push "billing-app"     "$BILLING_APP_TAG"     "./srcs/billing-app"
build_and_push "api-gateway"     "$API_GATEWAY_TAG"     "./srcs/api-gateway"

log "All images built and pushed! :)"