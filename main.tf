terraform {
  required_providers {
    tailscale = {
      source = "tailscale/tailscale"
      version = "0.22.0"
    }
  }
}

provider "tailscale" {
  oauth_client_id = env("TAILSCALE_OAUTH_CLIENT_ID")
  oauth_client_secret = env("TAILSCALE_OAUTH_CLIENT_SECRET")
}