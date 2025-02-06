variable "name" {
  description = "Name tag for the EBS volume"
  type        = string
}

variable "availability_zone" {
  description = "The AZ where the EBS volume will exist"
  type        = string
}

variable "volume_size" {
  description = "The size of the drive in GiBs"
  type        = number
}

variable "volume_type" {
  description = "The type of EBS volume. Can be standard, gp2, gp3, io1, io2, sc1 or st1"
  type        = string
  default     = "gp3"
}

variable "encrypted" {
  description = "If true, the disk will be encrypted"
  type        = bool
  default     = true
}

variable "iops" {
  description = "The amount of IOPS to provision for the disk. Only valid for type io1, io2, gp3"
  type        = number
  default     = null
}

variable "throughput" {
  description = "The throughput that the volume supports, in MiB/s. Only valid for type gp3"
  type        = number
  default     = null
}

variable "snapshot_id" {
  description = "A snapshot to base the EBS volume off of"
  type        = string
  default     = null
}

variable "instance_id" {
  description = "ID of the Instance to attach to"
  type        = string
  default     = null
}

variable "device_name" {
  description = "The device name to expose to the instance (for example, /dev/sdh or xvdh)"
  type        = string
  default     = "/dev/sdh"
}

variable "force_detach" {
  description = "Set to true if you want to force the volume to detach"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to the EBS volume"
  type        = map(string)
  default     = {}
}