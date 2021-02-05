//vpc
variable "vpc_name" {
  default = "lo_vpc"
}

variable "vpc_cidr" {
  default = "192.168.0.0/16"
}


//subnet
variable "subnet_name" {
  default = "subnet_1"
}

variable "subnet_cidr" {
  default = "192.168.0.0/24"
}

variable "subnet_gateway_ip" {
  default = "192.168.0.1"
}


//nat
variable "nat_gateway_name" {
  default = "nat_for_lo"
}

//eip



resource "flexibleengine_vpc_v1" "vpc_v1" {
  name = var.vpc_name
  cidr = var.vpc_cidr
}

resource "flexibleengine_vpc_subnet_v1" "subnet_v1" {
  name       = var.subnet_name
  cidr       = var.subnet_cidr
  gateway_ip = var.subnet_gateway_ip
  vpc_id     = flexibleengine_vpc_v1.vpc_v1.id
}

resource "flexibleengine_nat_gateway_v2" "nat_1" {
  name                = var.nat_gateway_name
  description         = "lo connector only needs access to liveobject endpoint, no need to expose to outside with public ip"
  spec                = "2"
  router_id           = flexibleengine_vpc_v1.vpc_v1.id
  internal_network_id = flexibleengine_vpc_subnet_v1.subnet_v1.id
}

resource "flexibleengine_vpc_eip_v1" "eip_1" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "test"
    size        = 8
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

resource "flexibleengine_nat_snat_rule_v2" "snat_1" {
  nat_gateway_id = flexibleengine_nat_gateway_v2.nat_1.id
  network_id     = flexibleengine_vpc_subnet_v1.subnet_v1.id
  floating_ip_id = flexibleengine_vpc_eip_v1.eip_1.id
}
