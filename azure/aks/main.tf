# Create an resource group
resource "azurerm_resource_group" "rg" {
  name     = var.rg-name
  location = var.location

  tags = var.tags
}

# VNET & Subnets
resource "azurerm_virtual_network" "vnet" {
  name                = var.aks-vnet-name
  location            = var.location
  resource_group_name = var.rg-name
  address_space       = var.vnet_address_space

  subnet {
    name           = var.aks-node-subnet-name
    address_prefix = var.node-subnet-address_prefix
  }

  subnet {
    name           = var.aks-pod-subnet-name
    address_prefix = var.pod-subnet-address_prefix
  }

  tags = var.tags

  depends_on = [azurerm_resource_group.rg]
}

data "azurerm_subnet" "node_subnet" {
  name                  = var.aks-node-subnet-name
  virtual_network_name  = var.aks-vnet-name
  resource_group_name   = var.rg-name

  depends_on = [azurerm_virtual_network.vnet]
}

data "azurerm_subnet" "pod_subnet" {
  name                  = var.aks-pod-subnet-name
  virtual_network_name  = var.aks-vnet-name
  resource_group_name   = var.rg-name

  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.aks_cluster.name
  location            = var.location
  resource_group_name = var.rg-name
  dns_prefix          = var.aks_cluster.dns_prefix
  kubernetes_version  = var.aks_cluster.kubernetes_version

  default_node_pool {
    name       = var.aks_cluster.node_pool.name
    zones      = var.aks_cluster.node_pool.zones
    vm_size    = var.aks_cluster.node_pool.vm_size

    enable_auto_scaling   = var.aks_cluster.node_pool.enable_auto_scaling
    enable_node_public_ip = var.aks_cluster.node_pool.enable_node_public_ip

    max_count             = var.aks_cluster.node_pool.max_count
    min_count             = var.aks_cluster.node_pool.min_count

    type                  = "VirtualMachineScaleSets"

    vnet_subnet_id        = data.azurerm_subnet.node_subnet.id
    pod_subnet_id         = data.azurerm_subnet.pod_subnet.id

    max_pods              = 100
    orchestrator_version  = var.aks_cluster.kubernetes_version
  }

  http_application_routing_enabled  = false
  role_based_access_control_enabled = true
  azure_policy_enabled              = true

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = var.aks_cluster.network_profile.network_plugin
    network_policy = var.aks_cluster.network_profile.network_policy
    service_cidr =  var.aks_cluster.network_profile.service_cidr
    dns_service_ip = var.aks_cluster.network_profile.dns_service_ip
    docker_bridge_cidr = var.aks_cluster.network_profile.docker_bridge_cidr
    load_balancer_sku = var.aks_cluster.network_profile.load_balancer_sku
  }
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  tags = var.tags

  depends_on = [azurerm_virtual_network.vnet]
}

# Data of AKS Cluster
data "azurerm_kubernetes_cluster" "aks_cluster_data" {
  name                = var.aks_cluster.name
  resource_group_name = var.rg-name

  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
}


# Create SA
resource "kubernetes_service_account" "ca_sa" {
  metadata {
    name      = var.ca_sa_name
    namespace = var.ca_sa_ns
  }

  secret {
    name = var.ca_sa_secret_name
  }

  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
}

# SA Token
resource "kubernetes_secret" "ca_sa_secret" {
  metadata {
    name = var.ca_sa_secret_name
    namespace = var.ca_sa_ns
    annotations = {
      "kubernetes.io/service-account.name" = var.ca_sa_name
    }
  }

  type = "kubernetes.io/service-account-token"

  depends_on = [kubernetes_service_account.ca_sa]
}

resource "kubernetes_cluster_role_binding" "aks_ca_crb" {
  metadata {
    name = "k8s-ca-crb"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.ca_sa_name
    namespace = var.ca_sa_ns
  }

  depends_on = [kubernetes_secret.ca_sa_secret]
}


data "kubernetes_secret" "ca_sa" {
  metadata {
    name      = var.ca_sa_name
    namespace = var.ca_sa_ns
  }

  depends_on = [kubernetes_cluster_role_binding.aks_ca_crb]
}

# DevOps Project
resource "azuredevops_project" "devops_project" {
  name         = var.devops_project_name
  description  = var.devops_project_desc

  depends_on = [data.kubernetes_secret.ca_sa]
}

# Create k8s service endpoint using SA
resource "azuredevops_serviceendpoint_kubernetes" "az_devops_sep" {

  apiserver_url         = "https://${data.azurerm_kubernetes_cluster.aks_cluster_data.fqdn}:443"
  authorization_type    = "ServiceAccount"

  project_id            = azuredevops_project.devops_project.id
  service_endpoint_name = var.devops_sep_name

  service_account {
    token   = base64encode(nonsensitive(lookup(data.kubernetes_secret.ca_sa.data, "token")))
    ca_cert = base64encode(nonsensitive(lookup(data.kubernetes_secret.ca_sa.data, "ca.crt")))
  }

  depends_on = [azuredevops_project.devops_project]
}