
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


output "flavors" {
  value = data.flexibleengine_compute_availability_zones_v2.myaz.names[0]
}

resource "flexibleengine_compute_keypair_v2" "keypair" {
  name       = "KeyPair-Dafu-Orange"
//public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAjpC1hwiOCCmKEWxJ4qzTTsJbKzndLotBCz5PcwtUnflmU+gHJtWMZKpuEGVi29h0A/+ydKek1O18k10Ff+4tyFjiHDQAnOfgWf7+b1yK+qDip3X1C0UPMbwHlTfSGWLGZqd9LvEFx9k3h/M+VtMvwR1lJ9LUyTAImnNjWG7TaIPmui30HvM2UiFEmqkr4ijq45MyX2+fLIePLRIF61p4whjHAQYufqyno3BS48icQb4p6iVEZPo4AE2o9oIyQvj2mx4dk5Y8CgSETOZTYDOR3rU2fZTRDRgPJDH9FWvQjF5tA0p3d9CoWWd2s6GKKbfoUIi8R/Db1BSPJwkqB"
}

resource "flexibleengine_cce_cluster_v3" "cluster_1" {
     name = "toto"
     cluster_type= "VirtualMachine"
     flavor_id= "cce.s2.medium"
     vpc_id= flexibleengine_vpc_v1.vpc_v1.id
     subnet_id= flexibleengine_vpc_subnet_v1.subnet_v1.id
     container_network_type= "overlay_l2"
     authentication_mode = "rbac"
     description= "Create cluster"
    }

resource "flexibleengine_cce_node_pool_v3" "node_pool" {
  cluster_id               = flexibleengine_cce_cluster_v3.cluster_1.id
  name                     = "testpool"
  os                       = "CentOS 7.7"
  initial_node_count       = 2
  flavor_id                = "s3.large.4"
  availability_zone        = null
  key_pair                 = flexibleengine_compute_keypair_v2.keypair.id
  scall_enable             = true
  min_node_count           = 1
  max_node_count           = 10
  scale_down_cooldown_time = 100
  priority                 = 1
  type                     = "vm"

  root_volume {
    size       = 40
    volumetype = "SAS"
  }
  data_volumes {
    size       = 100
    volumetype = "SAS"
  }
  timeouts {
    create = "30m"
    delete = "2h"
  }
}

