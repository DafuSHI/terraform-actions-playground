
variable "vpc_name" {
  default = "test_vpc"
}

variable "vpc_cidr" {
  default = "192.168.0.0/16"
}


//subnet
variable "subnet_name" {
  default = "subnet_01"
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


terraform {
  required_providers {
    flexibleengine = {
      source = "FlexibleEngineCloud/flexibleengine"
      version = "1.18.1"
    }
  }
  required_version = ">= 0.13"
}

provider "flexibleengine" {
  auth_url    = "https://iam.eu-west-0.prod-cloud-ocb.orange-business.com/v3"
  region      = "eu-west-0"
}


data "flexibleengine_compute_availability_zones_v2" "myaz" {}


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

resource "flexibleengine_vpc_eip_v1" "rest_api_eip" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name = "rest_api_eip_bandwidth"
    size = "1"
    share_type = "PER"
    charge_mode = "traffic"
  }
}

#ENHANCED LOAD BALANCER
resource "flexibleengine_lb_loadbalancer_v2" "elb_rest_api" {
  name              = "elb_rest_api"
  admin_state_up    = true
  vip_subnet_id     = flexibleengine_vpc_subnet_v1.subnet_v1.subnet_id

}

