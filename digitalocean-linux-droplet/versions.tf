terraform {
  required_providers {
    digitalocean = {
            source = "digitalocean/digitalocean"
            version = "~>2.67"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = ">= 0.13.13"
    }
  }
}
