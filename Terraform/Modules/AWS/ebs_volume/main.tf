resource "aws_ebs_volume" "this" {
  availability_zone = var.availability_zone
  size             = var.volume_size
  type             = var.volume_type
  encrypted        = var.encrypted
  iops             = var.iops
  throughput       = var.throughput
  snapshot_id      = var.snapshot_id
  
  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_volume_attachment" "this" {
  count = var.instance_id != null ? 1 : 0

  device_name  = var.device_name
  volume_id    = aws_ebs_volume.this.id
  instance_id  = var.instance_id
  force_detach = var.force_detach
}
