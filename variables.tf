variable "ibmcloud_timeout" {
  description = "Timeout for API operations in seconds."
  default     = 3600
}

variable "iaas_ssh_key" {
  description = "Classic environment SSH public Key"
  default = "ssh public key detail information"
}

variable "iaas_ssh_label" {
  description = "Classic environment SSH Label"
  default = "IaaS SSH Label"
}

variable "iaas_ssh_notes" {
  description = "Classic environment SSH Notes"
  default = "IaaS SSH Notes"
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

variable "ssh_keyname" {
  default = ""
  description = "The sshkey name tat will be used to create vsis in the VPC. Required for users to specify."
}

variable vpc_instance_count {
  default = 1
}

variable "vpc_vsi_instance_name" {
  default     = "zhut-test"
  description = "The name of the virtual server instance in the VPC. Required for users to specify."
}
variable "vpc_vsi_profile" {
  default     = "cx2-2x4"
  description = "The profile of compute CPU and memory resources to use when creating the virtual server instance in VPC. To list available profiles, run the `ibmcloud is instance-profiles` command."
}

variable "baremetal_hostname" {
  default = "bms-demo"
  description = "The name of the Bare Metal server in the Classic environment. Required for users to specify."
}

variable "vsi_hostname" {
  default = "vsi-demo"
  description = "The name of the virtual server instance in the Classic environment. Required for users to specify."
}

variable "computers_datacenter" {
  default = "dal12"
}
