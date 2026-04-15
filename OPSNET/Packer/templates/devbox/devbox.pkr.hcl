packer {
  required_version = ">= 1.11.0"

  required_plugins {
    proxmox = {
      version = ">= 1.1.8"
      source  = "github.com/hashicorp/proxmox"
    }
    windows-update = {
      version = "0.16.7"
      source  = "github.com/rgl/windows-update"
    }
  }
}



#########
# SOURCE
#########

source "proxmox-iso" "win10" {
    
    # Proxmox Connection
    node                     = "pve"
    proxmox_url              = var.proxmox_api_url
    username                 = var.proxmox_api_token_id 
    token                    = var.proxmox_api_token_secret 
    insecure_skip_tls_verify = true
    
    # General Settings
    template_name            = "devbox-opsnet-template"
    vm_name                  = var.vm_name
    

    # VM Configuration Settings
    os                       = var.os
    sockets                  = var.sockets
    cores                    = var.cores
    cpu_type                 = var.cpu_type
    memory                   = var.memory
    iso_storage_pool         = var.iso_storage_pool
    scsi_controller          = "virtio-scsi-single"
    iso_file                 = var.iso_file
    cloud_init = true
    cloud_init_storage_pool = "local"

    network_adapters {
          bridge    = var.bridge
          firewall  = var.firewall
      }
    
    disks {
          disk_size    = var.disk_size
          format       = var.disk_format
          storage_pool = var.disk_storage_pool
          type         = "ide"
      }
    
    
    additional_iso_files {
          unmount          = true
          device           = "ide3"
          #ide2 is used by Windows ISO
          iso_storage_pool = var.iso_storage_pool
          cd_files         = ["mount/Autounattend.xml", "mount/WinRM-Config.ps1", "mount/Install-Agent.ps1", "mount/cloudbase/cloudbase.ps1", 
                              "mount/cloudbase/cloudbase-init.conf" ]
          cd_label         = "cidata"
    }
    
    additional_iso_files {
            unmount          = true
            device           = "sata1"
            iso_storage_pool = "local"
            iso_file         = "local:iso/virtio-win.iso"
      }

    winrm_username           = var.builder_username
    winrm_password           = var.builder_password
    communicator             = "winrm"
    winrm_insecure           = true
    winrm_use_ntlm           = true
  }

########
# BUILD
########

build {
  sources = ["source.proxmox-iso.win10"]

  
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true"
    ]
    update_limit = 25
  }
  
  provisioner "windows-shell" {
    inline = ["shutdown /s /t 5 /f /d p:4:1 /c \"Packer Shutdown\""]
  }
 
}