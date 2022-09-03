variable "location" {
  type = string
}

variable "rg-name" {
  type = string
}

variable "aks-vnet-name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "aks-node-subnet-name" {
  type = string
}

variable "aks-pod-subnet-name" {
  type = string
}

variable "node-subnet-address_prefix" {
  type = string
}

variable "pod-subnet-address_prefix" {
  type = string
}

variable "aks_cluster" {
  type = object({

    name        = string
    dns_prefix  = string
    kubernetes_version = string

    node_pool = object({
      name                  = string
      zones                 = list(number)
      vm_size               = string
      enable_auto_scaling   = bool
      enable_node_public_ip = bool
      max_count             = number
      min_count             = number
    })

    network_profile = object({
      network_plugin      = string
      network_policy      = string
      pod_cidr            = string
      service_cidr        = string
      dns_service_ip      = string
      docker_bridge_cidr  = string
      load_balancer_sku   = string
    })
  })

}

variable "tags" {
  type = map(string)
}