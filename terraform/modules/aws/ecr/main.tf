# resource "aws_ecr_repository" "app_repos" {
#   for_each = toset([
#     "inventory-app",
#     "billing-app",
#     "api-gateway-app",
#     "rabbitmq",
#     "postgres-db"
#   ])

#   name                 = each.value
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }

#   tags = { "Name" = "cloud-design-${each.value}-ecr" }
# }