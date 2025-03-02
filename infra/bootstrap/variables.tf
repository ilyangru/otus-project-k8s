# common Selectel account variables
variable "sel_auth_url" {
  type = string
  default = "https://cloud.api.selcloud.ru/identity/v3"
}
variable "sel_account_id" {
  # openstack domain name
  # цифровой код аккаунта Селектел
  type = string
}
variable "sel_admin_user" {
  # openstack admin service user name
  type = string
}
variable "sel_admin_password" {
  # openstack admin service user password
  type = string
  sensitive = true
}

# Project variables
variable "sel_project_region" {
  # openstack region
  type = string
  default = "ru-2"
}
variable "project_name" {
  type = string
  default = "k8s"
}
variable "project_stage" {
  type = string
  default = "project"
}

# NODES CONFIG VARIABLES
variable "system_node_group" {   # SYSTEM (control-plane and bastion) nodes
  type = map(object({     # Explanation for OpenStack:
    type = string         #   Node flavor
    image = string        #   Node image name
    datacenter = string   #   Node availability zone
    count = number        #   How much nodes in group
    public_ip4 = bool     #   Needs public IPv4 ?
    labels = list(string) #   Server and k8s node labels, like "labelName=labelValue"
    taints = list(string) #   k8s node taints, like "taintKey=taintValue:Effect"
  }))
  default = {
    control-plane = {
      type = "sys"
      image = "Ubuntu 22.04 LTS 64-bit"
      datacenter = "ru-2c"
      count = 3
      public_ip4 = false
      labels = []
      taints = []
    }
    bastion = {
      type = "bastion"
      image = "Ubuntu 22.04 LTS 64-bit"
      datacenter = "ru-2c"
      count = 1
      public_ip4 = true
      labels = []
      taints = []
    }
  }
}
variable "static_worker_node_group" {   # STATIC WORKERS (https://docs.kubermatic.com/kubeone/v1.9/guides/static-workers/) nodes
  type = map(object({     # Explanation for OpenStack:
    type = string         #   Node flavor
    image = string        #   Node image name
    datacenter = string   #   Node availability zone
    count = number        #   Initial node count
    public_ip4 = bool     #   Needs public IPv4 ?
    labels = list(string) #   Server and k8s node labels, like "labelName=labelValue"
    taints = list(map(string)) #   k8s node taints, like "taintKey=taintValue:Effect"
  }))
  default = {
  }
}
variable "worker_node_group" {   # WORKERS (MachineDeployments CRDs) nodes
  type = map(object({     # Explanation for OpenStack:
    type = string         #   Node flavor
    image = string        #   Node image name
    datacenter = string   #   Node availability zone
    count = number        #   Initial node count
    public_ip4 = bool     #   Needs public IPv4 ?
    labels = list(string) #   Server and k8s node labels, like "labelName=labelValue"
    taints = list(string) #   k8s node taints, like "taintKey=taintValue:Effect"
  }))
  default = {
    demo = {
      type       = "worker"
      image      = "Ubuntu 22.04 LTS 64-bit"
      datacenter = "ru-2c"
      count      = 0
      public_ip4 = false
      labels     = []
      taints     = []
    }
  }
}
variable "flavor" {
  type = map(object({
    vcpus = number
    ram   = number
    disk  = number
    is_ephemeral = bool
    swap  = number
  }))
  default = {
    sys = {
      vcpus = 2
      ram   = 4096
      disk  = 10
      is_ephemeral = true
      swap  = 0
    }
    bastion = {
      vcpus = 1
      ram   = 2048
      disk  = 5
      is_ephemeral = true
      swap  = 0
    }
    worker = {
      vcpus = 2
      ram   = 4096 #8192
      disk  = 10
      is_ephemeral = true
      swap  = 0
    }
  }
}
