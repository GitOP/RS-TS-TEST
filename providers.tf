terraform {
  required_version = ">= 1.5.0"
    required_providers {
        digitalocean = {
            source = "digitalocean/digitalocean"
            version = "~>2.67"
        }
        tailscale = {
            source = "tailscale/tailscale"
            version = "~>0.22"
        }
    }
}

provider "digitalocean" {
  token = var.digitalocean_token
}

provider "tailscale" {
  oauth_client_id = var.tailscale_oauth_client_id
  oauth_client_secret = var.tailscale_oauth_client_secret
}