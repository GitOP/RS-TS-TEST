data "digitalocean_ssh_key" "terraform" {
  # name = "03:7c:34:d1:9d:19:5b:5e:a5:b8:79:4b:fe:07:5e:04"
  name = "macos-rsolis-lapm3.pub"
}

#Prevent errors caused by existing VPC
resource "random_id" "unique" {
    byte_length = 2  # 4-character hex string
}

locals {
    subnet_cidr = var.subnet_cidr
}

resource "digitalocean_vpc" "vpc_nyc" {
  name = "${var.region_nyc}-${random_id.unique.hex}"
  region = var.region_nyc
  ip_range = var.subnet_cidr
}

# There's no clean way to have a private-network only droplet?
# resource "digitalocean_vpc_nat_gateway" "vpc_nyc-nat" {
#   name   = "vpc_nyc-nat"
#   type   = "PUBLIC"
#   region = "nyc3"
#   size   = "1"
#   vpcs {
#     vpc_uuid = digitalocean_vpc.vpc_nyc.id
#   }
#   udp_timeout_seconds  = 30
#   icmp_timeout_seconds = 30
#   tcp_timeout_seconds  = 30
#  }

resource "digitalocean_droplet" "nyc_internal_resource" {
  name = "nyc-internal-resource"
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
    source_addresses = [local.subnet_cidr]  # Internal only
  }
  inbound_rule {
    protocol = "udp"
    port_range = "all"
    source_addresses = [local.subnet_cidr]  # Internal only
  }
  inbound_rule {
    protocol = "icmp"
    source_addresses = [local.subnet_cidr]  # Internal only
  }

  outbound_rule {
    protocol = "tcp"
    port_range = "all"
    destination_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol = "icmp"
    destination_addresses = [local.subnet_cidr]
  }
}

resource "digitalocean_droplet" "subnet_router_1" {
  name = "subnet-router-1"
  region = var.region_nyc
  size = var.droplet_size
  image = var.droplet_image
  monitoring = "true"
  ipv6 = false

  user_data = templatefile(
                "${path.module}/cloud-init-router.yaml",
                    { 
                        # Pass key created with the tf tailscale provider to cloud-init
                        TS_AUTH_KEY = tailscale_tailnet_key.subnet_router_1.key,
                        # Pass tailscale prefs
                        TAILSCALE_OPTS = join(" ", local.tailscale_set_preferences)
                        # Pass list of routes to be advertised by this node to cloud-init
                        ADVERTISED_ROUTES = join(",",local.advertised_routes)
                    }
                )

  vpc_uuid = digitalocean_vpc.vpc_nyc.id
  ssh_keys = [data.digitalocean_ssh_key.terraform.id]
}

resource "digitalocean_droplet" "external_resource" {
  name = "external-resource"
  region = var.region_tor
  size = var.droplet_size
  image = var.droplet_image
  monitoring = "true"
  ipv6 = false

  user_data = templatefile(
                "${path.module}/cloud-init-external.yaml",
                    { 
                        # Pass key created with the tf tailscale provider to cloud-init
                        TS_AUTH_KEY = tailscale_tailnet_key.external_resource.key
                        # Pass tailscale prefs
                        TAILSCALE_OPTS = join(" ", local.tailscale_set_preferences)
                    }
                )
  
  ssh_keys = [data.digitalocean_ssh_key.terraform.id]
}