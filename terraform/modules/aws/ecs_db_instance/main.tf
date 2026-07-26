data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_instance" "db_host" {
  ami                    = data.aws_ssm_parameter.ecs_ami.value
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.iam_instance_profile_name

  user_data = <<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.cluster_name} >> /etc/ecs/ecs.config
    echo 'ECS_INSTANCE_ATTRIBUTES={"role": "${var.host_name}-host"}' >> /etc/ecs/ecs.config

    echo "MOUNT_DEBUG: waiting for /dev/${var.device_name}"
    for i in $(seq 1 30); do
      [ -e /dev/${var.device_name} ] && echo "MOUNT_DEBUG: symlink appeared after $${i} tries" && break
      sleep 2
    done
    if [ ! -e /dev/${var.device_name} ]; then
      echo "MOUNT_DEBUG: TIMED OUT waiting for /dev/${var.device_name} to appear"
    fi

    DEVICE=$(readlink -f /dev/${var.device_name})
    echo "MOUNT_DEBUG: readlink resolved to $${DEVICE}"

    if [ -n "$DEVICE" ] && [ -e "$DEVICE" ]; then
      echo "MOUNT_DEBUG: device exists, proceeding with mount"
      if ! file -s $DEVICE | grep -q ext4; then
        echo "MOUNT_DEBUG: not ext4, formatting"
        mkfs -t ext4 $DEVICE
      else
        echo "MOUNT_DEBUG: already ext4, skipping format"
      fi
      mkdir -p /mnt/${var.host_name}
      mount $DEVICE /mnt/${var.host_name}
      mkdir -p /mnt/${var.host_name}/pgdata
      chmod 777 /mnt/${var.host_name}/pgdata
      echo "$DEVICE /mnt/${var.host_name} ext4 defaults,nofail 0 2" >> /etc/fstab
      echo "MOUNT_DEBUG: mount complete, df output:"
      df -h /mnt/${var.host_name}
    else
      echo "MOUNT_DEBUG: DEVICE CHECK FAILED - device does not exist, skipping mount entirely"
    fi
  EOF


  tags = { Name = "cloud-design-${var.host_name}-instance" }
}
