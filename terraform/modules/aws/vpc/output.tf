output "vpc_id" {
  value = aws_vpc.cloud-design-vpc.id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public: s.id ]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private: s.id ]
}

# output "nginx_sd_1" {
#   value = aws_service_discovery_service.nginx_sd_1.arn
# }

# output "nginx_sd_2" {
#   value = aws_service_discovery_service.nginx_sd_2.arn
# }

# output "dns_namespace" {
#   value = aws_service_discovery_private_dns_namespace.local.arn
# }

output "service_discovery_namespace_arn" {
  value = aws_service_discovery_http_namespace.local.arn
}