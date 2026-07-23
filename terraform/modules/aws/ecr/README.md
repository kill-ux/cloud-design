# AWS Elastic Container Registry (ECR) Module

This module manages **Elastic Container Registry (ECR)** repositories for building and storing Docker container images (`api-gateway-app`, `inventory-app`, `billing-app`, `rabbitmq`, `postgres-db`).

---

## Resources Managed

| Resource | Type | Description |
| :--- | :--- | :--- |
| `aws_ecr_repository.app_repos` | ECR Repositories | Private repositories for container microservices |

---

## Best Practices & Requirements

- **Image Scanning**: Ensure `scan_on_push = true` is enabled to automatically scan images for security vulnerabilities upon upload.
- **Tag Mutability**: Consider using `IMMUTABLE` tags in production to prevent image tag overwriting (`1.0.0`, `latest`).
- **Lifecycle Policies**: Add an `aws_ecr_lifecycle_policy` to automatically clean up old untagged container images and optimize storage costs.
