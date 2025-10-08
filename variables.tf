# ---- Parametrization vars

variable "subnets" {
  description = "List of subnet routers to deploy"
  type = list(object({
    name = string
    region = string
    cidr = string
  }))
  default = [
    {
      name = "nyc3"
      region = "nyc3"
      cidr = "10.10.10.0/24"
    },
    # Demo multi-subnetrouters in different regions
    {
      name = "sfo3"
      region = "sfo3"
      cidr = "10.20.20.0/24"
    },
    {
      name = "sgp"
      region = "sgp1"
      cidr = "10.30.30.0/24"
    }
  ]
}

variable "region_tor" {
  description = "DigitalOcean region for external droplet"
  type        = string
  default     = "tor1"
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
