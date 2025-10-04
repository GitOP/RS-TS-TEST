data "digitalocean_ssh_key" "terraform" {
  # name = "03:7c:34:d1:9d:19:5b:5e:a5:b8:79:4b:fe:07:5e:04"
  name = "macos-rsolis-lapm3.pub"
}

resource "random_id" "unique" {
  byte_length = 4  # produces an 8-character hex string
}

resource "digitalocean_vpc" "vpc_nyc" {
  name = "nyc3-vpc-${random_id.unique.hex}"
  region = "nyc3"
  ip_range = "10.10.10.0/24"
}

resource "digitalocean_droplet" "nyc_internal_resource" {
  name = "nyc-internal-resource"
  region = digitalocean_vpc.vpc_nyc.region
  size = "s-1vcpu-512mb-10gb"
  image = "ubuntu-25-04-x64"
  monitoring = "true"
  ipv6 = false

  vpc_uuid = digitalocean_vpc.vpc_nyc.id

  ssh_keys = [data.digitalocean_ssh_key.terraform.id]
}

resource "digitalocean_firewall" "block_public" {
  name = "block-public"

  droplet_ids = [digitalocean_droplet.nyc_internal_resource.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "all"
    source_addresses = ["10.10.10.0/24"]  # Only internal
  }
  inbound_rule {
    protocol         = "udp"
    port_range       = "all"
    source_addresses = ["10.10.10.0/24"]  # Only internal
  }
  inbound_rule {
    protocol = "icmp"
    source_addresses = ["10.10.10.0/24"]
  }

  outbound_rule {
    protocol = "tcp"
    port_range = "all"
    destination_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol = "icmp"
    destination_addresses = ["10.10.10.0/24"]
  }
}

resource "digitalocean_droplet" "subnet_router" {
  name = "subnet-router"
  region = digitalocean_vpc.vpc_nyc.region
  size = "s-1vcpu-512mb-10gb"
  image = "ubuntu-25-04-x64"
  monitoring = "true"
  ipv6 = false

  user_data = templatefile(
                "${path.module}/cloud-init-router.yaml",
                    { 
                        TSKEY_ROUTER = var.tskey_router
                    }
                )

  vpc_uuid = digitalocean_vpc.vpc_nyc.id
  ssh_keys = [data.digitalocean_ssh_key.terraform.id]
}

resource "digitalocean_droplet" "external_resource" {
  name = "external-resource"
  region = "tor1"
  size = "s-1vcpu-512mb-10gb"
  image = "ubuntu-25-04-x64"
  monitoring = "true"
  ipv6 = false

  user_data = templatefile(
                "${path.module}/cloud-init-external.yaml",
                    { 
                        TSKEY_EXTERNAL = var.tskey_external
                    }
                )
  
  ssh_keys = [data.digitalocean_ssh_key.terraform.id]
}