# RS-TS-TEST — DigitalOcean + Tailscale Subnet Router

This example provisions:
- A **DigitalOcean VPC** (`10.10.10.0/24`) in `nyc3`
- An **internal droplet** reachable only inside the VPC
- A **Tailscale subnet router** in the same VPC that **advertises the VPC subnet**
- An **external droplet** in `tor1` for connectivity tests
- A **Tailscale ACL** policy applied from `acl.hujson.tftpl`
- Shared **Tailscale preferences** and **tags** declared as Terraform locals for consistency across all nodes
- All Tailscale nodes are configured to launch the **ts-ssh server** but only the **external droplet** is enabled via **ts-ssh-enabled** tag

> Reusing and adapting patterns from the official [Tailscale IaC examples](https://github.com/tailscale-dev/examples-infrastructure-as-code): provider version pinning, variable parameterization, `cloud-init` bootstrap, reusable locals, and useful outputs.

## Prerequisites

- DigitalOcean API token (`var.digitalocean_token`)
- Tailscale OAuth client credentials (`var.tailscale_oauth_client_id`, `var.tailscale_oauth_client_secret`), which the provider uses to mint ephemeral **tailnet keys** for the router and external nodes.

## Configuration Highlights

### Variables
The example now uses a `variables.tf` file to parameterize regions, droplet sizes, and images:

| Variable | Default | Description |
|-----------|----------|-------------|
| `region_nyc` | `"nyc3"` | Region for internal and router droplets |
| `region_tor` | `"tor1"` | Region for external droplet |
| `subnet_cidr` | `"10.10.10.0/24"` | CIDR block of the VPC subnet |
| `droplet_size` | `"s-1vcpu-512mb-10gb"` | Droplet size slug |
| `droplet_image` | `"ubuntu-25-04-x64"` | Base image for all droplets |

### Locals
Inspired on the locals found in the IaC examples, `tailscale.tf` defines shared tags and preferences used by cloud-init and ACLs:

```hcl
locals {
  {
        infra          = "tag:infra"
        exitnode       = "tag:exitnode"
        appconnector   = "tag:appconnector"
        subnet_router  = "tag:subnet-router"
        ssh_enabled    = "tag:ts-ssh-enabled"
        toronto        = "tag:Toronto"
        newyork        = "tag:NewYork"
    }

  tailscale_set_preferences = [
    "--auto-update",
    "--ssh",
    "--advertise-routes=${join(",", local.advertised_routes)}",
    "--accept-dns=false",
  ]

## Usage

```bash
terraform init
terraform apply
```

After apply, Terraform will print useful **outputs** (public/private IPs, regions, VPC ID).

### Verifying
- In the Tailscale admin, confirm both nodes joined.
- Ensure the router node shows the **advertised route** `10.10.10.0/24` and that clients in your tailnet can reach the internal droplet’s **private IP** via the router.

## Notes

- The `tailscale_acl` resource **overwrites** the tailnet policy. If you already have an ACL policy managed elsewhere, **import** it before first apply:

```bash
terraform import tailscale_acl.as_hujson acl
```

## Cleanup

```bash
terraform destroy
```
