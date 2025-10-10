# RS-TS-TEST — DigitalOcean + Tailscale Subnet Router

This example provisions:
- A DigitalOcean VPC (10.10.10.0/24) in nyc3
- An `internal resource` reachable only inside the VPC
- A Tailscale `subnet router` in the same VPC that advertises the VPC subnet
- A second Tailscale node `external resource` registered to the same tailnet in tor1 for connectivity tests
- A Tailscale ACL policy generated dynamically by Terraform from `acl.hujson.tftpl`
- Shared Tailscale tags declared as Terraform locals for consistency across all nodes
- All Tailscale nodes are configured to launch the ts-ssh server, but only the `external resource` is enabled via the ts-ssh-enabled tag

![alt text](https://github.com/GitOP/RS-TS-TEST/blob/main/assets/digitalocean-tailscale-diagram.png?raw=true)
  
The project reuses modules from [Tailscale IaC examples](https://github.com/tailscale-dev/examples-infrastructure-as-code):
- **tailscale-install-scripts/**: generates bash/cloud-init install scripts for Tailscale (used with no changes)
- **digitalocean-linux-droplet/**: wraps droplet creation (inspired by azure-linux-vm)

## Prerequisites

- DigitalOcean API token `var.digitalocean_token`
- Tailscale OAuth client credentials `var.tailscale_oauth_client_id`, `var.tailscale_oauth_client_secret` which the provider uses to create ephemeral tailnet keys for the router and external nodes.

Security note:
Handle API credentials carefully. I use [Doppler](https://www.doppler.com/) (doppler run --name-transformer tf-var -- terraform apply) to avoid committing credentials to version control or exposing them in the console.

## Initialize and Deploy

```bash
terraform init          # or doppler run --name-transformer tf-var -- terraform init
terraform plan          # or doppler run --name-transformer tf-var -- terraform plan
terraform apply         # or doppler run --name-transformer tf-var -- terraform apply
```

Terraform will:
1. Create a VPC, firewall, and droplets.
2. Apply the ACL policy to your Tailscale tailnet.
3. Create two preauthorized Tailscale auth keys.
4. Bootstrap both droplets using the tailscale-install-scripts module via user_data.
5. Join both nodes to your tailnet and configure routing automatically.
6. Print useful outputs such as public/private IPs, regions, and the VPC ID.

### Verifying

- In the Tailscale admin console, confirm both nodes have joined.
- Ensure the router node shows the advertised route.
- Confirm that clients in your tailnet can reach the internal droplet’s private IP via the router.

To check Tailscale install logs on the droplet:

```bash
sudo tail -f /var/log/tailscale-install.log
```
## Notes

The tailscale_acl resource overwrites the tailnet policy.
If you already have an ACL policy managed elsewhere, import it before the first apply:

```bash
terraform import tailscale_acl.as_hujson acl
```
## Cleanup

To remove all resources:

```bash
terraform destroy
```

This will:
- Remove droplets and firewall rules
- Delete the VPC
- Invalidate the temporary Tailscale keys

## How It Works

Each droplet uses a Terraform module that injects a dynamically generated bash install script at boot time.
This script:
1. Installs the latest Tailscale client.
2. Joins the tailnet with a temporary key.
3. Applies tags, routing, and SSH preferences.
4. Logs progress to /var/log/tailscale-install.log.

The subnet router additionally enables IP forwarding and advertises its internal subnet.

All configuration is derived from Terraform locals and passed into the Tailscale provider, ensuring a fully reproducible deployment.

## Module Overview

- **digitalocean-linux-droplet:** Creates droplets with Tailscale installed and configuration controlled by its `tailscale_set_preferences`.
- **tailscale-install-scripts:** Generates and logs the full bash/cloud-init setup for Tailscale
- **Root (this project):** Provisions the networking, ACLs, and tailnet configuration

### Dynamic Tailscale Tag Generation

Based on the locals defined in `tailscale.tf`, tags are automatically injected into the ACL via the Tailscale Terraform ACL resource.
This allows automatic approval of routes based on the permissions assigned when Tailscale auth keys are generated for each node.

## Configuration Highlights

The project is fully parameterized to support **multiple regions and subnet routers**, making it easy to scale the Tailnet topology by simply extending variable lists or maps.  
All values can be customized via a `.tfvars` file or environment variables.

| **Variable / Local** | **Default** | **Description** |
|-----------------------|-------------|-----------------|
| `subnets` | `[ { name = "nyc3", region = "nyc3", cidr = "10.10.10.0/24" } ]` | List of subnet router definitions. Each entry defines a region, name, and CIDR block. Terraform loops over this list to provision a router and its associated VPC. |
| `droplet_size` | `"s-1vcpu-512mb-10gb"` | [Droplet size slug](https://slugs.do-api.dev/) used for all droplets (routers, internal, and external). |
| `droplet_image` | `"ubuntu-25-04-x64"` | Base image for all Tailscale nodes. |
| `tailscale_tags` | `[ "tag:subnet-router", "tag:infra" ]` | Default Tailscale tags applied to nodes. |
| `tailscale_acl_template` | `"acl.hujson.tftpl"` | Template used to dynamically generate the ACL policy based on subnets and tags. |

### Example override in `terraform.tfvars`

```hcl
subnets = [
  { name = "nyc3", region = "nyc3", cidr = "10.10.10.0/24" },
  { name = "sfo1", region = "sfo3", cidr = "10.20.20.0/24" },
  { name = "tor1", region = "tor1", cidr = "10.40.40.0/24" }
]
```
