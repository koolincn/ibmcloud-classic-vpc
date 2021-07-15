data "ibm_is_image" "ds_image" {
  name = "ibm-centos-7-6-minimal-amd64-2"
}

data "ibm_is_ssh_key" "ds_key" {
  name = var.ssh_keyname
}

data "ibm_resource_group" "group" {
  is_default = "true"
}

resource "ibm_compute_ssh_key" "ssh_key" {
  public_key = "${var.iaas_ssh_key}"
}

resource "ibm_is_vpc" "vpc" {
  name           = var.vpc_name
  resource_group = data.ibm_resource_group.group.id
}

resource "ibm_is_security_group" "sg1" {
  name = "${var.basename}-sg1"
  vpc  = ibm_is_vpc.vpc.id
}

# allow all incoming ping
resource "ibm_is_security_group_rule" "ingress_imp" {
  group     = ibm_is_security_group.sg1.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  icmp {
    type = 8
  }
}

# allow all incoming network traffic on port 22
resource "ibm_is_security_group_rule" "ingress_ssh_all" {
  group     = ibm_is_security_group.sg1.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 22
    port_max = 22
  }
}

# allow all incoming network traffic on port 80
resource "ibm_is_security_group_rule" "ingress_web_all" {
  group     = ibm_is_security_group.sg1.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 80
    port_max = 80
  }
}

# allow all incoming network traffic on port 443
resource "ibm_is_security_group_rule" "ingress_secweb_all" {
  group     = ibm_is_security_group.sg1.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 443
    port_max = 443
  }
}

# allow all incoming network traffic on port 3306 (mysql port)
resource "ibm_is_security_group_rule" "ingress_db_all" {
  group     = ibm_is_security_group.sg1.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 3306
    port_max = 3306
  }
}

# allow all outcoming network traffic on port 80
resource "ibm_is_security_group_rule" "egress_all_web" {
  group     = ibm_is_security_group.sg1.id
  direction = "outbound"

  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "egress_all_secweb" {
  group     = ibm_is_security_group.sg1.id
  direction = "outbound"

  tcp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "egress_all_dns_tcp" {
  group     = ibm_is_security_group.sg1.id
  direction = "outbound"

  tcp {
    port_min = 53
    port_max = 53
  }
}

resource "ibm_is_security_group_rule" "egress_all_dns_udp" {
  group     = ibm_is_security_group.sg1.id
  direction = "outbound"

  udp {
    port_min = 53
    port_max = 53
  }
}

resource "ibm_is_security_group_rule" "egress_all_range" {
  group     = ibm_is_security_group.sg1.id
  direction = "outbound"

  tcp {
    port_min = 1024
    port_max = 32768
  }
}

resource "ibm_is_public_gateway" "cloud" {
  vpc   = ibm_is_vpc.vpc.id
  name  = "${var.basename}-pubgw"
  zone  = var.subnet_zone
}

resource "ibm_is_vpc_address_prefix" "vpc_address_prefix" {
  name = "${var.basename}-prefix"
  zone = var.subnet_zone
  vpc  = ibm_is_vpc.vpc.id
  cidr = "192.168.0.0/24"
}

resource "ibm_is_subnet" "subnet" {
  name            = "${var.basename}-subnet"
  vpc             = ibm_is_vpc.vpc.id
  zone            = var.subnet_zone
  resource_group  = data.ibm_resource_group.group.id
  public_gateway  = ibm_is_public_gateway.cloud.id
  ipv4_cidr_block = ibm_is_vpc_address_prefix.vpc_address_prefix.cidr
}

resource "ibm_is_instance" "instance" {
  count          = var.vpc_instance_count
  name           = "${var.basename}-instance-${count.index}"
  vpc            = ibm_is_vpc.vpc.id
  zone           = var.subnet_zone
  profile        = "cx2-2x4"
  image          = data.ibm_is_image.ds_image.id
  keys           = [data.ibm_is_ssh_key.ds_key.id]
  resource_group = data.ibm_resource_group.group.id

  primary_network_interface {
    subnet = ibm_is_subnet.subnet.id
    security_groups = [ibm_is_security_group.sg1.id]
  }
}

resource "ibm_is_floating_ip" "fip1" {
  name   = "${var.basename}-fip1"
  target = ibm_is_instance.instance[0].primary_network_interface[0].id
}

output "sshcommand" {
  value = "ssh root@${ibm_is_floating_ip.fip1.address}"
}

/* Feild to Edit transit gateway */
 resource "ibm_tg_gateway" "new_tg_gw"{
  name = "tg_demo"
  location = var.region
  global = true
  resource_group = data.ibm_resource_group.group.id
 }
 resource "ibm_tg_connection" "ibm_tg_vpc_connection"{
  gateway = ibm_tg_gateway.new_tg_gw.id
  network_type = "vpc"
  name = "vpc_tg"
  network_id = ibm_is_vpc.vpc.resource_crn
 }
# Classic transit gate connect need VRF enabled
# resource "ibm_tg_connection" "ibm_tg_clasic_connection"{
#  gateway = ibm_tg_gateway.new_tg_gw.id
#  network_type = "classic"
#  name = "classic_tg"
# }

/* Feilds to Edit while provisioning Virtual Machine */
 
 resource "ibm_compute_vm_instance" "vsi-provisions" {
  hostname = "${var.vsi_hostname}"
  domain = "zhutingsh.com"
  network_speed = 1000
  hourly_billing = true
  os_reference_code = "CENTOS_7_64"
  cores = 1
  memory = 2048
  disks = [25]
  local_disk = false
  datacenter = "${var.computers_datacenter}"
  private_network_only = false
  ssh_key_ids = ["${ibm_compute_ssh_key.ssh_key.id}"]
 } 

/* Feilds to Edit while provisioning Bare Metal */
 
# resource "ibm_compute_bare_metal" "bm-provisions" {
#  hostname = "${var.baremetal_hostname}"
#  domain = "zhutingsh.com"
#  network_speed = 1000
#  hourly_billing = true
#  os_reference_code = "UBUNTU_20_64"
#  fixed_config_preset = "1U_1270_V6_2X2TB_NORAID"
#  datacenter = "${var.computers_datacenter}"
#  private_network_only = false
# } 
# output "classic_bms_ips" {
#   value = "ibm_compute_bare_metal.bm-provisions.public_ipv4_address"
# }
 output "classic_vsi_ips" {
   value = ibm_compute_vm_instance.vsi-provisions.ipv4_address
 }
