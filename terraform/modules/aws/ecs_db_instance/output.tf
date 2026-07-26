output "instance_id" {
  value = aws_instance.db_host.id
}
output "placement_attribute" {
  value = "${var.host_name}-host"
}