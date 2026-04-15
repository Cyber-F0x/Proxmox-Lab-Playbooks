

packer {
    required_plugins {
        proxmox = {
            version = ">= 1.1.1"
            source  = "github.com/hashicorp/proxmox"
        }
    }
}

source "proxmox-iso" "c2" {
    # Connection Details
    insecure_skip_tls_verify = true
    proxmox_url              = var.proxmox_api_url
    username                 = var.proxmox_api_token_id 
    token                    = var.proxmox_api_token_secret 
    node                     = "pve"
   
    task_timeout = "10m" 

    # Host Configuration
    iso_file = "local:iso/ubuntu-24.04.1-live-server-amd64.iso"
    iso_storage_pool = "local"
    unmount_iso      = true

    memory = 4098
    cores  = 4
    os     = "l26"

    network_adapters {
        model  = "virtio"
        bridge = "OPSNET" 
    }

    disks {
        type              = "scsi"
        disk_size         = "32G"
        storage_pool      = "local-lvm"
        storage_pool_type = "lvm"
    }

    # Packer
    additional_iso_files {
        cd_files         = ["./cidata/*"]
        cd_label         = "cidata"
        unmount          = true
        iso_storage_pool = "local"
    }
    qemu_agent           = true 
    cloud_init = true
    cloud_init_storage_pool = "local"

    ssh_username         = var.ssh_username
    ssh_password         = var.ssh_password
    #ssh_private_key_file = "~/.ssh/packer"
    ssh_timeout          = "25m"

    boot = "order=scsi0;ide2;"
    boot_wait = "15s"
    boot_command = [
        "<esc><wait>",
        "<esc><wait>",
        "c<wait>",
        "set gfxpayload=keep",
        "<enter><wait>",
        "linux /casper/vmlinuz quiet<wait>",
        " autoinstall<wait>",
        " ds=nocloud;<wait>",
        "<enter><wait>",
        "initrd /casper/initrd",
        "<enter><wait>",
        "boot<enter><wait>",
    ]

    template_name = "c2-server-opsnet-template"
    
}

build {
  name = "ubuntu-x86_64"
  sources = ["source.proxmox-iso.c2"]

  # Clean up the machine for cloud-init
  provisioner "shell" {
    execute_command = "echo 'ubuntu' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo ssh-keygen -A",      
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo sync"
    ]
  }
}