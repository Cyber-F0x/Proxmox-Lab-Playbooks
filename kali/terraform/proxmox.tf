resource "proxmox_vm_qemu" "lab" {
    clone = "kali-2025-base-20260302-1757"
    target_node = "pve"

    name    = "kali-opsnet"
    cpu {
         sockets = 2
         cores   = 8
        }
    
    memory  = 16384

    
    disk {
        type    = "disk"
        slot    = "scsi0"
        storage = "local-lvm"
        size    = "128G"
    }

  network {
    id     = 0
    bridge = "OPSNET"
    model  = "virtio"
  }
}