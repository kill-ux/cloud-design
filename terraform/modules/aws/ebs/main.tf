resource "aws_ebs_volume" "ebs" {
  availability_zone = var.availability_zone
  size              = var.ebs_size
  type              = var.ebs_type
  tags              = var.tags
  encrypted = true
}

resource "aws_volume_attachment" "ebs_attachment" {
  device_name = var.device_name
  volume_id   = aws_ebs_volume.ebs.id
  instance_id = var.instance_id
}