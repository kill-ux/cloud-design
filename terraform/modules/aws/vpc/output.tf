output "vpc_id" {
  value = aws_vpc.cloud-design-vpc.id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}

output "service_discovery_namespace_arn" {
  value = aws_service_discovery_private_dns_namespace.local.arn
}

output "availability_zone" {
  description = "Availability zone for the EBS volume"
  value       = aws_subnet.private.availability_zone
}
