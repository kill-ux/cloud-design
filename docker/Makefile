# Makefile — build and push Docker images
.DEFAULT_GOAL := build-push

DOMAIN_USER ?= killux3k
POSTGRES_DB ?= 1.0.0
BILLING_QUEUE_TAG ?= 1.0.0
INVENTORY_APP_TAG ?= 1.0.0
BILLING_APP_TAG ?= 1.0.0
API_GATEWAY_TAG ?= 1.0.0

# Image names
INVENTORY_IMAGE := $(DOMAIN_USER)/inventory-app:$(INVENTORY_APP_TAG)
BILLING_IMAGE := $(DOMAIN_USER)/billing-app:$(BILLING_APP_TAG)
API_GATEWAY_IMAGE := $(DOMAIN_USER)/api-gateway-app:$(API_GATEWAY_TAG)
RABBITMQ_IMAGE := $(DOMAIN_USER)/rabbitmq:$(BILLING_QUEUE_TAG)
POSTGRES_IMAGE := $(DOMAIN_USER)/postgres-db:$(POSTGRES_DB)

.PHONY: build push build-push clean help

build: ## Build all images
	@echo "[+] Building inventory-app..."
	docker build -t $(INVENTORY_IMAGE) ./srcs/inventory-app
	@echo "[+] Building billing-app..."
	docker build -t $(BILLING_IMAGE) ./srcs/billing-app
	@echo "[+] Building api-gateway-app..."
	docker build -t $(API_GATEWAY_IMAGE) ./srcs/api-gateway
	@echo "[+] Building rabbitmq..."
	docker build -t $(RABBITMQ_IMAGE) ./srcs/rabbitmq
	@echo "[+] Building postgres-db..."
	docker build -t $(POSTGRES_IMAGE) ./srcs/postgres-db
	@echo "[+] All images built!"

push: ## Push all images
	@echo "[+] Pushing inventory-app..."
	docker push $(INVENTORY_IMAGE)
	@echo "[+] Pushing billing-app..."
	docker push $(BILLING_IMAGE)
	@echo "[+] Pushing api-gateway-app..."
	docker push $(API_GATEWAY_IMAGE)
	@echo "[+] Pushing rabbitmq..."
	docker push $(RABBITMQ_IMAGE)
	@echo "[+] Pushing postgres-db..."
	docker push $(POSTGRES_IMAGE)
	@echo "[+] All images pushed!"

build-push: build push ## Build and push all images
	@echo "[+] All images built and pushed!"

clean: ## Remove local images
	@echo "[+] Removing local images..."
	docker rmi $(INVENTORY_IMAGE) || true
	docker rmi $(BILLING_IMAGE) || true
	docker rmi $(API_GATEWAY_IMAGE) || true
	docker rmi $(RABBITMQ_IMAGE) || true
	docker rmi $(POSTGRES_IMAGE) || true

help: ## Show this help
	@echo "Usage: make [target]"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'