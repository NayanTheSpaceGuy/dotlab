terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }
  backend "http" {}
}

variable "pve_api_url" {
  type      = string
  sensitive = true
}

variable "pve_user" {
  type = string
}

variable "pve_password" {
  type      = string
  sensitive = true
}

variable "general_ci_password" {
  type      = string
  sensitive = true
}
provider "proxmox" {
  pm_api_url  = var.pve_api_url
  pm_user     = var.pve_user
  pm_password = var.pve_password
}
