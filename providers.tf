provider "ibm" {
  region           = var.region
  generation       = 2
  iaas_classic_username = var.iaas_classic_username
  iaas_classic_api_key  = var.iaas_classic_api_key
  ibmcloud_timeout = var.ibmcloud_timeout
}
