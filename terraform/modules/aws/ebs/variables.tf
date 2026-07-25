
variable "availability_zone" {
  description = "The availability zone in which to create the EBS volume."
  type        = string
}

variable "ebs_size" {
  description = "The size of the EBS volume in GiBs."
  type        = number
}

variable "ebs_type" {
  description = "The type of the EBS volume (e.g., gp2, io1, st1, sc1)."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the EBS volume."
  type        = map(string)
  default     = {}
}

variable "instance_id" {
  description = "The ID of the EC2 instance to attach the EBS volume to."
  type        = string
}

variable "device_name" {
  description = "The device name to expose to the EC2 instance (e.g., /dev/sdh)."
  type        = string
}