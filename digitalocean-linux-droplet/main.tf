module "tailscale_install_scripts" {
  source = "../tailscale-install-scripts"

  tailscale_auth_key        = var.tailscale_auth_key
  tailscale_hostname        = var.tailscale_hostname
  tailscale_set_preferences = var.tailscale_set_preferences

  additional_before_scripts = var.additional_before_scripts
  additional_after_scripts  = var.additional_after_scripts
}

resource "digitalocean_droplet" "do-linux-droplet" {
  name = var.name
  region = var.location
  size = var.size
  image = var.image
  monitoring = "true"
  ipv6 = false

  user_data = module.tailscale_install_scripts.ubuntu_install_script

  # Value can't be empty - null if not defined
  vpc_uuid = var.vpc_uuid != "" ? var.vpc_uuid : null
  ssh_keys = var.ssh_keys

  lifecycle {
    ignore_changes = [image]
  }
}
