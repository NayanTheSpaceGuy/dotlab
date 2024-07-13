terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }
  backend "http" {}
}

variable "PVE_API_URL" {
  type      = string
  sensitive = true
}

variable "PVE_USER" {
  type = string
}

variable "PVE_PASSWORD" {
  type      = string
  sensitive = true
}

variable "GENERAL_CI_PASSWORD" {
  type      = string
  sensitive = true
}

variable "PUBLIC_SSH_KEYS" {
  type = string
  sensitive = true
}

provider "proxmox" {
  pm_api_url  = var.PVE_API_URL
  pm_user     = var.PVE_USER
  pm_password = var.PVE_PASSWORD
}
