module "ebs_volume" {
  source = "./modules/aws/ebs_volume"

  name              = "example-volume"
  availability_zone = "us-west-2a"
  volume_size       = 100
  volume_type       = "gp3"
  encrypted        = true
  
  # Optional: Specify for gp3 volumes
  iops             = 3000
  throughput       = 125

  # Optional: Attach to an EC2 instance
  instance_id      = "i-1234567890abcdef0"
  device_name      = "/dev/sdh"
  
  tags = {
    Environment = "Production"
    Project     = "Example"
    Terraform   = "true"
  }
}
