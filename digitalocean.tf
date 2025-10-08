data "digitalocean_ssh_key" "terraform" {
  # name = "03:7c:34:d1:9d:19:5b:5e:a5:b8:79:4b:fe:07:5e:04"
  name = "macos-rsolis-lapm3.pub"
}

#Prevent errors caused by existing VPC
resource "random_id" "unique" {
    byte_length = 2  # 4-character hex string
}

resource "digitalocean_vpc" "vpc" {
  for_each = { for s in var.subnets : s.name => s }

  name     = "vpc-${each.key}-${random_id.unique.hex}"
  region   = each.value.region
  ip_range = each.value.cidr
}

resource "digitalocean_droplet" "nyc_internal_resource" {
  name = "internal-resource"
  region = digitalocean_vpc.vpc["nyc3"].region
  size = var.droplet_size
  image = var.droplet_image
  monitoring = "true"
  ipv6 = false

  vpc_uuid = digitalocean_vpc.vpc["nyc3"].id

  ssh_keys = [data.digitalocean_ssh_key.terraform.id]
}

resource "digitalocean_firewall" "block_public" {
  name = "block-public-inbound"

  droplet_ids = [digitalocean_droplet.nyc_internal_resource.id]

  inbound_rule {
    protocol = "tcp"
    port_range = "all"
    source_addresses = [digitalocean_vpc.vpc["nyc3"].ip_range]  # Internal only
  }
  inbound_rule {
    protocol = "udp"
    port_range = "all"
    source_addresses = [digitalocean_vpc.vpc["nyc3"].ip_range]  # Internal only
  }
  inbound_rule {
    protocol = "icmp"
    source_addresses = [digitalocean_vpc.vpc["nyc3"].ip_range]  # Internal only
  }

  outbound_rule {
    protocol = "tcp"
    port_range = "all"
    destination_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol = "icmp"
    destination_addresses = [digitalocean_vpc.vpc["nyc3"].ip_range]
  }
}

module "digitalocean_linux_droplet_subnet_router" {
  for_each = { for s in var.subnets : s.name => s }

  source = "./digitalocean-linux-droplet"
  
  name = "ts-router-${each.key}"
  location = each.value.region
  size = var.droplet_size
  image = var.droplet_image
  vpc_uuid = digitalocean_vpc.vpc[each.key].id
  ssh_keys = [data.digitalocean_ssh_key.terraform.id]

  # tailscale_hostname   = "subnet-router-${each.key}"
  tailscale_auth_key   = tailscale_tailnet_key.subnet_router_key[each.key].key

  tailscale_set_preferences = [
      "--auto-update",
      "--ssh",
      "--accept-dns=false",
      "--accept-routes",
      "--advertise-routes=${join(",", [each.value.cidr])}"
    ]
  additional_before_scripts = []
  additional_after_scripts = []

  depends_on = [ tailscale_tailnet_key.subnet_router_key ]
}

module "digitalocean_linux_droplet_external_resource" {
  source = "./digitalocean-linux-droplet"
  name = "external-resource"
  location = var.region_tor
  size = var.droplet_size
  image = var.droplet_image
  ssh_keys = [data.digitalocean_ssh_key.terraform.id]
  
  # tailscale_hostname = "external-resource"
  tailscale_auth_key   = tailscale_tailnet_key.external_resource.key
  tailscale_set_preferences = local.tailscale_preferences_external_resource
  additional_before_scripts = []
  additional_after_scripts = []
  
  depends_on = [ tailscale_tailnet_key.external_resource ]
}
