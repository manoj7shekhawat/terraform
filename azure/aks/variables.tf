variable "location" {
  type = string
}

variable "rg-name" {
  type = string
}

variable "aks-name" {
  type = string
}

variable "dns-prefix" {
  type = string
}

variable "node-pool-name" {
  type = string
}

variable "node-pool-size" {
  type = string
}

variable "tags" {
  type = map(string)
}