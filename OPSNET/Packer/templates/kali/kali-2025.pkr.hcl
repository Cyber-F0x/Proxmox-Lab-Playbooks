
packer {
    required_plugins {
        proxmox = {
            version = ">= 1.1.1"
            source  = "github.com/hashicorp/proxmox"
        }
    }
}


source "proxmox-iso" "kali" {
    # Connection Details
    insecure_skip_tls_verify = true
    proxmox_url              = var.proxmox_api_url
    username                 = var.proxmox_api_token_id 
    token                    = var.proxmox_api_token_secret 
    node                     = "pve"
   
    task_timeout = "10m" 

    # Host Configuration
    #iso_url          = "https://cdimage.kali.org/kali-2025.4/kali-linux-2025.4-installer-amd64.iso"
    #iso_checksum     = "sha256:3b4a3a9f5fb6532635800d3eda94414fb69a44165af6db6fa39c0bdae750c266"
    iso_file = "local:iso/04a694cae2e4aaba6abc5674f3bf9632dd7039d2.iso"
    iso_storage_pool = "local"
    unmount_iso      = true

    memory = 16384
    cores  = 8
    os     = "l26"

    network_adapters {
        model  = "virtio"
        bridge = "OPSNET" 
    }

    disks {
        type              = "scsi"
        disk_size         = "128G"
        storage_pool      = "local-lvm"
        storage_pool_type = "lvm"
    }

    # Packer
    qemu_agent           = true 
    cloud_init           = true
    cloud_init_storage_pool = "local"

    # Communication Settings
    
    ssh_username         = var.ssh_username
    ssh_password         = var.ssh_password
    ssh_private_key_file = "~/.ssh/packer"
    ssh_timeout          = "25m"
    
    # HTTP settings for Preseed
    http_directory = "http"
    http_port_min = 8800
    http_port_max = 8800
    http_bind_address = "0.0.0.0"

    # UK English Boot Command for Debian/Kali Installer
    boot_wait = "15s"
    boot_command = [
        "<esc><wait>",
        "install <wait>",
        "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>", 
        "debian-installer=en_GB.UTF-8 <wait>",
        "auto <wait>",
        "locale=en_GB.UTF-8 <wait>",
        "kbd-chooser/method=uk <wait>",
        "keyboard-configuration/xkb-keymap=uk <wait>",
        "keyboard-configuration/layoutcode=gb <wait>",
        "netcfg/get_hostname=kali-opsnet <wait>",
        "netcfg/get_domain=local <wait>",
        "fb=false <wait>",
        "debconf/frontend=noninteractive <wait>",
        "console-setup/ask_detect=false <wait>",
        "<enter>" 
    ]

    template_name = "kali-opsnet-template"
}

build {
    name    = "kali-x86_64"
    sources = ["source.proxmox-iso.kali"]

    # 1. Upload your custom cloud-init configuration
    provisioner "file" {
        # Point this to the specific user-data file you had in your cidata folder
        source      = "./cidata/user-data" 
        destination = "/tmp/99-custom-cloud-init.cfg"
    }

    # 2. Move it to the correct directory and secure it
    provisioner "shell" {
            # Feed the SSH password directly into sudo for the entire script execution
            execute_command = "echo '${var.ssh_password}' | sudo -S env {{ .Vars }} {{ .Path }}"
            
            inline = [
                "apt-get update",
                "systemctl enable ssh"
                "apt-get install -y cloud-init",
                "mv /tmp/99-custom-cloud-init.cfg /etc/cloud/cloud.cfg.d/99-custom-cloud-init.cfg",
                "chown root:root /etc/cloud/cloud.cfg.d/99-custom-cloud-init.cfg",
                "chmod 644 /etc/cloud/cloud.cfg.d/99-custom-cloud-init.cfg",
                "truncate -s 0 /etc/machine-id"
            ]
        }
}