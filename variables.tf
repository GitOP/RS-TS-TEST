# ---- Parametrization vars

variable "region_nyc" {
  description = "DigitalOcean region for internal and router droplets"
  type        = string
  default     = "nyc3"
}

variable "region_tor" {
  description = "DigitalOcean region for external droplet"
  type        = string
  default     = "tor1"
}

variable "subnet_cidr" {
  description = "VPC subnet CIDR range"
  type        = string
  default     = "10.10.10.0/24"
}

variable "droplet_size" {
  description = "DigitalOcean droplet size slug"
  type        = string
  default     = "s-1vcpu-512mb-10gb"
}

variable "droplet_image" {
  description = "Base image for droplets"
  type        = string
  default     = "ubuntu-25-04-x64"
}

# ---- API Auth vars

variable "digitalocean_token" {
  type = string
  sensitive = true
  description = "DigitalOcean API token"
}

variable "tailscale_oauth_client_id" {
    type = string
    sensitive = true
    description = "Tailscale OAuth client key"
}

variable "tailscale_oauth_client_secret" {
    type = string
    sensitive = true
    description = "Tailscale OAuth client secret" 
}
