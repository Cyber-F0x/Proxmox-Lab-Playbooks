terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
    ansible = {
      source = "ansible/ansible"
      version = "1.4.0"
    }
  }
}

variable "proxmox_api_url"{
type = string 
}

variable "proxmox_api_token_id"{
type = string 
sensitive = true
}

variable "proxmox_api_token_secret"{
type = string 
sensitive = true
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/inventory.ini"
  
  content = templatefile("${path.module}/inventory.tftpl", {
    # Reference the specific instance created by the for_each loop using its map key
    kali_ip   = proxmox_vm_qemu.opsnet["target-1"].default_ipv4_address
    ubuntu_ip = proxmox_vm_qemu.opsnet["target-2"].default_ipv4_address
    win_ip    = proxmox_vm_qemu.opsnet["target-3"].default_ipv4_address
  })
}

provider "proxmox" {
    pm_api_url = var.proxmox_api_url
    pm_api_token_id = var.proxmox_api_token_id
    pm_api_token_secret = var.proxmox_api_token_secret
    pm_tls_insecure = true
}


