.PHONY: help init plan apply destroy fmt validate clean ssh cluster services

# Colors
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m

help:
	@echo "$(GREEN)Terraform Makefile$(NC)"
	@echo ""
	@echo "$(YELLOW)Targets:$(NC)"
	@echo "  init            Initialize Terraform"
	@echo "  validate        Validate configuration"
	@echo "  fmt             Format .tf files"
	@echo "  plan            Plan changes"
	@echo "  apply           Apply changes"
	@echo "  destroy         Destroy infrastructure"
	@echo "  destroy-keep-ecr Destroy all except ECR"
	@echo "  output          Show outputs"
	@echo "  state-list      List state resources"
	@echo "  state-show      Show resource (RESOURCE=module.xxx)"
	@echo "  ssh             SSH into ECS instance"
	@echo "  cluster         Show cluster info"
	@echo "  services        Show services info"
	@echo "  clean           Clean cache and locks"

init:
	@echo "$(GREEN)Initializing Terraform...$(NC)"
	terraform init

validate:
	@echo "$(GREEN)Validating configuration...$(NC)"
	terraform validate

fmt:
	@echo "$(GREEN)Formatting .tf files...$(NC)"
	terraform fmt -recursive

plan: validate
	@echo "$(GREEN)Planning changes...$(NC)"
	terraform plan -var-file=env.tfvars -out=tfplan

apply:
	@echo "$(YELLOW)Applying changes...$(NC)"
	@read -p "Continue? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		terraform apply -var-file=env.tfvars; \
	else \
		echo "$(RED)Cancelled$(NC)"; \
	fi

apply-tfplan:
	@echo "$(YELLOW)Applying tfplan...$(NC)"
	@read -p "Continue? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		terraform apply tfplan; \
	else \
		echo "$(RED)Cancelled$(NC)"; \
	fi

destroy:
	@echo "$(RED)DESTROYING all infrastructure...$(NC)"
	@read -p "Type 'destroy' to confirm: " confirm; \
	if [ "$$confirm" = "destroy" ]; then \
		terraform destroy -var-file=env.tfvars; \
	else \
		echo "$(RED)Cancelled$(NC)"; \
	fi

destroy-keep-ecr:
	@echo "$(RED)Removing ECR from state...$(NC)"
	terraform state rm 'module.ecr'
	@echo "$(RED)DESTROYING infrastructure (keeping ECR)...$(NC)"
	@read -p "Type 'destroy' to confirm: " confirm; \
	if [ "$$confirm" = "destroy" ]; then \
		terraform destroy -var-file=env.tfvars; \
	else \
		echo "$(YELLOW)Restoring ECR...$(NC)"; \
		echo "$(RED)Cancelled$(NC)"; \
	fi

output:
	@echo "$(GREEN)Terraform outputs:$(NC)"
	terraform output

state-list:
	@echo "$(GREEN)State resources:$(NC)"
	terraform state list

state-show:
	@if [ -z "$(RESOURCE)" ]; then \
		echo "$(RED)Error: RESOURCE not specified$(NC)"; \
		echo "Usage: make state-show RESOURCE=module.xxx"; \
		exit 1; \
	fi
	@echo "$(GREEN)Showing $(RESOURCE)...$(NC)"
	terraform state show '$(RESOURCE)'

refresh:
	@echo "$(GREEN)Refreshing state...$(NC)"
	terraform refresh -var-file=env.tfvars

clean:
	@echo "$(YELLOW)Cleaning cache...$(NC)"
	rm -rf .terraform tfplan .terraform.lock.hcl
	@echo "$(GREEN)Cleaned$(NC)"

# AWS CLI commands
ssh:
	@echo "$(YELLOW)Connecting to ECS instance...$(NC)"
	@INSTANCE_IP=$$(aws ec2 describe-instances \
		--filters "Name=tag:aws:autoscaling:groupName,Values=cloud-design-ecs-asg" \
		--query 'Reservations[0].Instances[0].PublicIpAddress' \
		--region eu-west-3 \
		--output text); \
	if [ -z "$$INSTANCE_IP" ] || [ "$$INSTANCE_IP" = "None" ]; then \
		echo "$(RED)No running instances found$(NC)"; \
	else \
		echo "$(GREEN)SSH to $$INSTANCE_IP$(NC)"; \
		ssh -i .keys/id_ecs ec2-user@$$INSTANCE_IP; \
	fi

cluster:
	@echo "$(GREEN)ECS Cluster Info:$(NC)"
	aws ecs describe-clusters \
		--clusters cloud-design-cluster \
		--region eu-west-3 \
		--query 'clusters[0].[clusterName,status,runningCount,pendingCount,registeredContainerInstancesCount]' \
		--output table

services:
	@echo "$(GREEN)ECS Services:$(NC)"
	aws ecs list-services \
		--cluster cloud-design-cluster \
		--region eu-west-3 \
		--output table

lint: fmt validate
	@echo "$(GREEN)Lint passed!$(NC)"

full-deploy: plan apply-tfplan
	@echo "$(GREEN)Deployment complete!$(NC)"

.DEFAULT_GOAL := help