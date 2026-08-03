.PHONY: help init plan apply destroy fmt validate clean ssm cluster services dev-shell lint refresh output state-list state-show destroy-keep-ecr apply-tfplan

# ---------- Defaults ----------
TF_DIR     ?= terraform/workload
AWS_REGION ?= eu-west-3

# ---------- Colors ----------
RED    := \033[0;31m
GREEN  := \033[0;32m
YELLOW := \033[0;33m
NC     := \033[0m

# ---------- Help ----------
help:
	@echo "$(GREEN)Terraform Makefile$(NC)"
	@echo ""
	@echo "$(YELLOW)Targets:$(NC)"
	@echo "  init              Initialize Terraform in \$$(TF_DIR)"
	@echo "  validate          Validate configuration"
	@echo "  fmt               Format .tf files"
	@echo "  plan              Plan changes"
	@echo "  apply             Apply changes"
	@echo "  apply-tfplan      Apply a saved tfplan"
	@echo "  destroy           Destroy infrastructure"
	@echo "  destroy-keep-ecr  Destroy all except ECR"
	@echo "  output            Show outputs"
	@echo "  state-list        List state resources"
	@echo "  state-show        Show resource (RESOURCE=module.xxx)"
	@echo "  refresh           Refresh state"
	@echo "  ssm               Pick an instance and SSM into it"
	@echo "  cluster           Show ECS cluster info"
	@echo "  services          Show ECS services"
	@echo "  dev-shell         Open an interactive shell in the dev container"
	@echo "  lint              fmt + validate"
	@echo "  clean             Clean \$$(TF_DIR)/.terraform and tfplan"
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make plan TF_DIR=terraform/foundation"
	@echo "  make apply TF_DIR=terraform/workload"
	@echo "  make state-show RESOURCE=module.alb.aws_lb.cloud_design_alb"

# ---------- Dev environment ----------
dev-shell:
	docker run -it --rm \
		-v $(shell pwd):/workspace \
		-v $(HOME)/.aws:/root/.aws \
		-e AWS_PROFILE \
		-e AWS_REGION \
		cloud-design-dev:latest

# ---------- Terraform commands ----------
init:
	@echo "$(GREEN)Initializing Terraform in $(TF_DIR)...$(NC)"
	cd $(TF_DIR) && terraform init

validate:
	@echo "$(GREEN)Validating $(TF_DIR)...$(NC)"
	cd $(TF_DIR) && terraform validate

fmt:
	@echo "$(GREEN)Formatting .tf files in $(TF_DIR)...$(NC)"
	cd $(TF_DIR) && terraform fmt -recursive

plan: validate
	@echo "$(GREEN)Planning $(TF_DIR)...$(NC)"
	cd $(TF_DIR) && terraform plan -out=tfplan

apply:
	@echo "$(YELLOW)About to apply in $(TF_DIR). Press Enter to continue, Ctrl+C to abort.$(NC)"
	@read _
	cd $(TF_DIR) && terraform apply

apply-tfplan:
	@echo "$(YELLOW)Applying tfplan in $(TF_DIR)...$(NC)"
	@[ -f $(TF_DIR)/tfplan ] || { echo "$(RED)No tfplan found. Run 'make plan' first.$(NC)"; exit 1; }
	cd $(TF_DIR) && terraform apply tfplan

destroy:
	@echo "$(RED)DESTROYING infrastructure in $(TF_DIR)...$(NC)"
	@read -p "Type 'destroy' to confirm: " confirm; \
	if [ "$$confirm" = "destroy" ]; then \
		cd $(TF_DIR) && terraform destroy; \
	else \
		echo "$(RED)Cancelled$(NC)"; \
	fi


output:
	@echo "$(GREEN)Terraform outputs for $(TF_DIR):$(NC)"
	cd $(TF_DIR) && terraform output

state-list:
	@echo "$(GREEN)State resources in $(TF_DIR):$(NC)"
	cd $(TF_DIR) && terraform state list

state-show:
	@if [ -z "$(RESOURCE)" ]; then \
		echo "$(RED)Error: RESOURCE not specified$(NC)"; \
		echo "Usage: make state-show RESOURCE=module.xxx.yyy"; \
		exit 1; \
	fi
	@echo "$(GREEN)Showing $(RESOURCE)...$(NC)"
	cd $(TF_DIR) && terraform state show '$(RESOURCE)'

refresh:
	@echo "$(GREEN)Refreshing state in $(TF_DIR)...$(NC)"
	cd $(TF_DIR) && terraform refresh

clean:
	@echo "$(YELLOW)Cleaning $(TF_DIR)/.terraform and tfplan...$(NC)"
	rm -rf $(TF_DIR)/.terraform $(TF_DIR)/tfplan
	@echo "$(GREEN)Cleaned$(NC)"

# ---------- AWS CLI commands ----------
ssm:
	@echo "$(GREEN)Running instances in $${AWS_REGION}:$(NC)"; \
	echo ""; \
	aws ec2 describe-instances \
		--region $${AWS_REGION} \
		--filters "Name=instance-state-name,Values=running" \
		--query 'Reservations[].Instances[].{ID:InstanceId,Name:Tags[?Key==`Name`]|[0].Value,IP:PrivateIpAddress,Type:InstanceType}' \
		--output table; \
	echo ""; \
	read -p "Enter Instance ID to connect: " CHOICE; \
	if [ -z "$$CHOICE" ]; then \
		echo "$(RED)No instance selected. Aborting.$(NC)"; \
		exit 1; \
	fi; \
	aws ssm start-session --target $$CHOICE --region $${AWS_REGION}

cluster:
	@echo "$(GREEN)ECS Cluster Info:$(NC)"
	aws ecs describe-clusters \
		--clusters cloud-design-cluster \
		--region $${AWS_REGION} \
		--query 'clusters[0].[clusterName,status,runningCount,pendingCount,registeredContainerInstancesCount]' \
		--output table

services:
	@echo "$(GREEN)ECS Services in cloud-design-cluster:$(NC)"
	aws ecs list-services \
		--cluster cloud-design-cluster \
		--region $${AWS_REGION} \
		--query 'serviceArns[]' \
		--output text | tr '\t' '\n' | xargs -I {} basename {} | awk '{print "  - " $$0}'

# ---------- Meta targets ----------
lint: fmt validate
	@echo "$(GREEN)Lint passed!$(NC)"

.DEFAULT_GOAL := help