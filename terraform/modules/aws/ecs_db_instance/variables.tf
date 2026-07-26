variable "host_name" {
  description = "Also used as the ECS placement attribute and /mnt mount dir (e.g. inventory-db)"
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "iam_instance_profile_name" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "device_name" {
  description = "Bare device suffix, e.g. sdh"
  type        = string
}
