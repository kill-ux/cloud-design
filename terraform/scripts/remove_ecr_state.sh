#!/bin/bash

terraform state rm 'module.ecr.aws_ecr_repository.app_repos["api-gateway-app"]'
terraform state rm 'module.ecr.aws_ecr_repository.app_repos["billing-app"]'
terraform state rm 'module.ecr.aws_ecr_repository.app_repos["inventory-app"]'
terraform state rm 'module.ecr.aws_ecr_repository.app_repos["postgres-db"]'
terraform state rm 'module.ecr.aws_ecr_repository.app_repos["rabbitmq"]'