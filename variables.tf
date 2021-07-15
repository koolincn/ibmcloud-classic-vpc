variable "ibmcloud_timeout" {
  description = "Timeout for API operations in seconds."
  default     = 3600
}

variable "iaas_ssh_key" {
  description = "Classic environment SSH public Key"
  default = "ssh public key detail information"
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

variable vpc_instance_count {
  default = 1
}

variable "baremetal_hostname" {
  default = "bms-demo"
}

variable "vsi_hostname" {
  default = "vsi-demo"
}

variable "computers_datacenter" {
  default = "dal12"
}
