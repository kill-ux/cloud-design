variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "description" {
  description = "Description of the security group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    description                  = string
    from_port                    = number
    to_port                      = number
    protocol                     = optional(string, "tcp")
    cidr_ipv4                    = optional(string)
    referenced_security_group_id = optional(string)
    self                         = optional(bool, false)
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    description = string
    from_port   = optional(number)
    to_port     = optional(number)
    protocol    = optional(string, "tcp")
    cidr_ipv4   = string
  }))
  default = [{
    description = "Allow all outbound"
    protocol    = "-1"
    cidr_ipv4   = "0.0.0.0/0"
  }]
}
variable "tags" {
  description = "Tags to apply to the security group"
  type        = map(string)
  default     = {}
}
