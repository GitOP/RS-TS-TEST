output "vpc_id" {
  description = "ID of the VPC created in nyc3"
  value       = digitalocean_vpc.vpc_nyc.id
}

output "subnet_cidr" {
  description = "CIDR of the VPC subnet"
  value       = digitalocean_vpc.vpc_nyc.ip_range
}

output "internal_private_ip" {
  description = "Private IPv4 of the internal resource droplet"
  value       = digitalocean_droplet.nyc_internal_resource.ipv4_address_private
}

output "router_public_ip" {
  description = "Public IPv4 of the subnet router droplet"
  value       = digitalocean_droplet.subnet_router_1.ipv4_address
}

output "external_public_ip" {
  description = "Public IPv4 of the external resource droplet"
  value       = digitalocean_droplet.external_resource.ipv4_address
}

output "router_region" {
  description = "Region of the router droplet"
  value       = digitalocean_droplet.subnet_router_1.region
}

output "external_region" {
  description = "Region of the external droplet"
  value       = digitalocean_droplet.external_resource.region
}
