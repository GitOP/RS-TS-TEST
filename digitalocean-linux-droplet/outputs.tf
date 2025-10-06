output "instance_id" {
  value = digitalocean_droplet.do-linux-droplet.id
}

# output "internal_domain_name_suffix" {
#   value = azurerm_network_interface.primary.internal_domain_name_suffix
# }

output "user_data_md5" {
  description = "MD5 hash of the VM user_data script - for detecting changes"
  value       = module.tailscale_install_scripts.ubuntu_install_script_md5
  sensitive   = true
}

output "ipv4_address" {
  description = "Public IPv4 address of the droplet"
  value       = digitalocean_droplet.do-linux-droplet.ipv4_address
}

output "region" {
  description = "Region where the droplet is deployed"
  value       = digitalocean_droplet.do-linux-droplet.region
}