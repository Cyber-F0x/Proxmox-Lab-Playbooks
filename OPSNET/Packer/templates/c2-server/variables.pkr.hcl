# variables.pkr.hcl

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

variable "ssh_username" {
  type        = string
  description = "The username to use for SSH connections" 
  sensitive   = true 
}

variable "ssh_password" {
  type        = string
  description = "The password to use for SSH connections" 
  sensitive   = true 
}

variable "ssh_pub" {
  type        = string
  description = "The public SSH key to inject into the authorized_keys file" 
  sensitive   = true 
}