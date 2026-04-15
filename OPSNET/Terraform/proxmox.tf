
locals {
  target_servers = {
    target-1 = {
      clone = "kali-opsnet-template"
      target_name = "kali-opsnet"
      cpu = {
          sockets = 2
          cores   = 4
          }
      memory  = 16384
      disk = {
          size    = "128G"
          slot = "scsi0"
      }
    }
    target-2 = {
      clone = "c2-server-opsnet-template"
      target_name = "c2-opsnet"
      cpu = {
          sockets = 1
          cores   = 4
          }
      memory  = 4098
      disk = {
          size    = "32G"
          slot = "scsi0"
      }
    }
    target-3 = {
      clone = "devbox-opsnet-template"
      target_name = "devbox-opsnet"
      cpu = {
          sockets = 2
          cores   = 4
          }
      memory  = 16384
      disk = {
          size    = "128G"
          slot = "ide0"

      }
    }     
  } 
}


resource "proxmox_vm_qemu" "opsnet" {
  for_each = local.target_servers
    name = each.value.target_name
    target_node = "pve"
    clone = each.value.clone
    full_clone = false
    cores = each.value.cpu.cores
    sockets = each.value.cpu.sockets
    memory = each.value.memory
    tags = "opsnet"
    agent = 1
    disk {
      type    = "disk"
      size = each.value.disk.size
      storage = "local-lvm"
      slot = each.value.disk.slot
    }
    network {
      id     = 0
      bridge = "OPSNET"
      model = "virtio"
      firewall = false
    }
  
}
