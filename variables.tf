variable "ibmcloud_timeout" {
  description = "Timeout for API operations in seconds."
  default     = 900
}

variable "iaas_classic_username" {}
variable "iaas_classic_api_key"  {}

variable "vpc_name" {}

variable "basename" {
  description = "Prefix used for all resource names"
}

variable "region" {
  default = "us-south"
}

variable "subnet_zone" {
  default = "us-south-1"
}

variable "ssh_keyname" {}

variable instance_count {
  default = 1
}
