terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.75.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    talos = {
      source = "siderolabs/talos"
      version = "~> 0.7.1"
    }
  }
}

# Configure the Proxmox provider
provider "proxmox" {
  endpoint = var.proxmox.endpoint
  insecure = var.proxmox.insecure
  api_token = var.proxmox.api_token
  ssh {
    agent    = true
    username = "root"
  }
}
