###############
# VM VARIABLES
###############
variable "proxmox_api_url" {
  type        = string
  description = "The full URL for the Proxmox API (e.g., https://pve.example.com:8006/api2/json)" 
}

variable "proxmox_api_token_id" {
  type        = string
  description = "The API Token ID for Proxmox authentication" 
  sensitive   = true 
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "The API Token Secret for Proxmox authentication" 
  sensitive   = true 
}

variable "vm_name" {
  type        = string
  description = "Name of VM Template"
  default     = ""
}

variable "os" {
  type        = string
  description = "VM Guest OS Type"
  default     = "win10"
}

variable "cores" {
  type        = string
  description = " How many CPU cores to give the virtual machine. Defaults to 1"
}

variable "cpu_type" {
  type        = string
  description = "The CPU type to emulate. See the Proxmox API documentation for the complete list of accepted values. For best performance, set this to host. Defaults to kvm64"
}

variable "sockets" {
  type        = string
  description = "How many CPU sockets to give the virtual machine. Defaults to 1"
}

variable "memory" {
  type        = string
  description = "Amount of RAM for VM"
}

variable "vm_cdrom_type" {
  type        = string
  description = "CDROM Type for VM"
  default     = ""
}

variable "disk_format" {
  type    = string
  description = "The format of the file backing the disk. Can be raw, cow, qcow, qed, qcow2, vmdk or cloop. Defaults to raw"
  default = ""
}

variable "disk_size" {
  type        = string
  description = "The size of the disk, including a unit suffix, such as 10G to indicate 10 gigabytes."
}

variable "disk_storage_pool" {
  type    = string
  description = "Name of the Proxmox storage pool to store the virtual machine disk on"
}

variable "vm_network" {
  type        = string
  description = "Desired Virtual Network to Connect VM To"
  default     = "vmbr0"
}

variable "bridge" {
  type        = string
  description = "Required. Which Proxmox bridge to attach the adapter to."
  default     = ""
}

variable "firewall" {
  type        = string
  description = "If the interface should be protected by the firewall. Defaults to false"
}

variable "vlan_tag" {
  type        = string
  description = "If the adapter should tag packets. Defaults to no tagging"
  default     = ""
}

variable "builder_username" {
  type        = string
  description = "VM Guest Username to Build With"
  default     = ""
}

variable "builder_password" {
  type        = string
  description = "VM Guest User's Password to Authenticate With"
  default     = ""
}

variable "iso_file" {
  type        = string
  description = "Path to Windows ISO"
  default     = ""
}

variable "template_description" {
  type        = string
  description = "Notes for VM Template"
  default     = "Windows 10 Pro Template "
}

variable "template_name" {
  type        = string
  description = "Name of the template. Defaults to the generated name used during creation"
}

variable "iso_storage_pool" {
  type        = string
  description = "Proxmox storage pool onto which to upload the ISO file."
}
