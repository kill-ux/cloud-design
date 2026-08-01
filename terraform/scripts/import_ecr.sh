#!/bin/bash

terraform import 'module.ecr.aws_ecr_repository.app_repos["inventory-app"]'   inventory-app
terraform import 'module.ecr.aws_ecr_repository.app_repos["billing-app"]'     billing-app
terraform import 'module.ecr.aws_ecr_repository.app_repos["api-gateway-app"]' api-gateway-app
terraform import 'module.ecr.aws_ecr_repository.app_repos["rabbitmq"]'        rabbitmq
terraform import 'module.ecr.aws_ecr_repository.app_repos["postgres-db"]'     postgres-db