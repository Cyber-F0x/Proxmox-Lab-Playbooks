packer {
    required_plugins {
        proxmox = {
            version = ">= 1.1.1"
            source  = "github.com/hashicorp/proxmox"
        }
    }
}

source "proxmox-iso" "pve" {
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

    # Communication Settings
    qemu_agent           = true 
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

    template_name = join("-", [
        "kali",
        "2025",
        "base",
        formatdate("YYYYMMDD-hhmm", timestamp()),
    ])
}

build {
    name    = "kali-x86_64"
    sources = ["source.proxmox-iso.pve"]

    # Post-Install Provisioning: Cleanup and SSH Key Injection
    provisioner "shell" {
        execute_command = "echo '${var.ssh_password}' | sudo -S -E sh -eux '{{ .Path }}'" 
        inline = [
            "mkdir -p /home/${var.ssh_username}/.ssh",
            "echo '${var.ssh_pub}' > /home/${var.ssh_username}/.ssh/authorized_keys", 
            "chown -R ${var.ssh_username}:${var.ssh_username} /home/${var.ssh_username}/.ssh",
            "chmod 700 /home/${var.ssh_username}/.ssh",
            "chmod 600 /home/${var.ssh_username}/.ssh/authorized_keys",
            
            # Machine Sanitization for Proxmox Templating
            "sudo rm -f /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt-get -y autoremove --purge",
            "sudo apt-get -y clean",
            "sudo sync" 
        ]
    }
}