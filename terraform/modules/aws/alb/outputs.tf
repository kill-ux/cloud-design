output "target_group_arn" {
  description = "ARN of the API Gateway Target Group"
  value       = aws_lb_target_group.cloud_design_gateway_tg.arn
}

output "alb_dns_name" {
  description = "DNS name of the Load Balancer"
  value       = aws_lb.cloud_design_alb.dns_name
}  
