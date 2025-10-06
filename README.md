# RS-TS-TEST — DigitalOcean + Tailscale Subnet Router

This example provisions:
- A **DigitalOcean VPC** (`10.10.10.0/24`) in `nyc3`
- An **internal droplet** reachable only inside the VPC
- A **Tailscale subnet router** in the same VPC that **advertises the VPC subnet**
- A secong Tailscale node **external droplet** registered to the same tailnet `tor1` for connectivity tests
- A **Tailscale ACL** policy generated dynamically by terraform from `acl.hujson.tftpl`
- Shared **Tailscale tags** declared as Terraform locals for consistency across all nodes
- All Tailscale nodes are configured to launch the **ts-ssh server** but only the **external droplet** is enabled via **ts-ssh-enabled** tag


  
> Reusing and adapting patterns from the official [Tailscale IaC examples](https://github.com/tailscale-dev/examples-infrastructure-as-code)

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

### Dynamic Tailscale tag generation
Based on the locals defined in "tailscale.tf", tags are automatically injected to the acl via the Tailscale terraform acl resource, this allows automatic approval of routes based in permissions assigned when tailscale-auth-keys are generated for the node.

### DigitalOcean Linux Droplet
Inspired on the IaC examples, a new terraform module `digitalocean-linux-vm` defines new droplets with tailscale installed and tailscale configuration dependant on its **tailscale_set_preferences**:

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
