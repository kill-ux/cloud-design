output "ecr_registry" {
  value = { for k, repo in aws_ecr_repository.app_repos : k => repo.repository_url }
}