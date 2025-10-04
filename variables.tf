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

variable "tskey_external" {
    type = string
    sensitive = true
    description = "Tailscale node key for non-vpc node"
}

variable "tskey_router" {
    type = string
    sensitive = true
    description = "Tailscale node key for subnet-router node"
}
