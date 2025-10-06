data "digitalocean_ssh_key" "terraform" {
  # name = "03:7c:34:d1:9d:19:5b:5e:a5:b8:79:4b:fe:07:5e:04"
  name = "macos-rsolis-lapm3.pub"
}

#Prevent errors caused by existing VPC
resource "random_id" "unique" {
    byte_length = 2  # 4-character hex string
}

locals {
    subnet_router_1_hostname = "subnet-router-1"
    external_resource_hostname = "external-resource"
    internal_resource_hostname = "internal-resource"

}

resource "digitalocean_vpc" "vpc_nyc" {
  name = "${var.region_nyc}-${random_id.unique.hex}"
  region = var.region_nyc
  ip_range = var.subnet_cidr
}

resource "digitalocean_droplet" "nyc_internal_resource" {
  name = local.internal_resource_hostname
  region = var.region_nyc
  size = var.droplet_size
  image = var.droplet_image
  monitoring = "true"
  ipv6 = false

  vpc_uuid = digitalocean_vpc.vpc_nyc.id

  ssh_keys = [data.digitalocean_ssh_key.terraform.id]
}

resource "digitalocean_firewall" "block_public" {
  name = "block-public-inbound"

  droplet_ids = [digitalocean_droplet.nyc_internal_resource.id]

  inbound_rule {
    protocol = "tcp"
    port_range = "all"
    source_addresses = [var.subnet_cidr]  # Internal only
  }
  inbound_rule {
    protocol = "udp"
    port_range = "all"
    source_addresses = [var.subnet_cidr]  # Internal only
  }
  inbound_rule {
    protocol = "icmp"
    source_addresses = [var.subnet_cidr]  # Internal only
  }

  outbound_rule {
    protocol = "tcp"
    port_range = "all"
    destination_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol = "icmp"
    destination_addresses = [var.subnet_cidr]
  }
}

module "tailscale_install_scripts_subnet_router_1" {
  source = "./tailscale-install-scripts"
  tailscale_hostname   = local.subnet_router_1_hostname
  tailscale_auth_key   = tailscale_tailnet_key.subnet_router_1.key
  tailscale_set_preferences = local.tailscale_preferences_subnet_router_1
  additional_before_scripts = []
  additional_after_scripts = []

  depends_on = [ tailscale_tailnet_key.subnet_router_1 ]
}

resource "digitalocean_droplet" "subnet_router_1" {
  name = local.subnet_router_1_hostname
  region = var.region_nyc
  size = var.droplet_size
  image = var.droplet_image
  monitoring = "true"
  ipv6 = false

  user_data = module.tailscale_install_scripts_subnet_router_1.ubuntu_install_script

  vpc_uuid = digitalocean_vpc.vpc_nyc.id
  ssh_keys = [data.digitalocean_ssh_key.terraform.id]
}

module "tailscale_install_scripts_external_resource" {
  source = "./tailscale-install-scripts"
  tailscale_hostname = local.external_resource_hostname
  tailscale_auth_key   = tailscale_tailnet_key.external_resource.key
  tailscale_set_preferences = local.tailscale_preferences_external_resource
  additional_before_scripts = []
  additional_after_scripts = []

  depends_on = [ tailscale_tailnet_key.external_resource ]
}

resource "digitalocean_droplet" "external_resource" {
  name = local.external_resource_hostname
  region = var.region_tor
  size = var.droplet_size
  image = var.droplet_image
  monitoring = "true"
  ipv6 = false

  user_data = module.tailscale_install_scripts_external_resource.ubuntu_install_script
  
  ssh_keys = [data.digitalocean_ssh_key.terraform.id]
}