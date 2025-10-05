# List of routes we need to approve
locals {
    advertised_routes = [local.subnet_cidr]
    subnet_tags = [for r in local.advertised_routes : "tag:subnet-${replace(r, "/[./]/", "-")}"]
}

resource "tailscale_tailnet_key" "subnet_router_1" {
    ephemeral           = true
    preauthorized       = true
    # Looks like there's no need for this - better suited for k8s and other scaling groups
    #   reusable            = true          
    recreate_if_invalid = "always"
    tags                = concat(local.subnet_tags,
                                ["tag:subnet-router","tag:newyork"])
    description         = "subnet-router"
}

resource "tailscale_tailnet_key" "external_resource" {
    ephemeral           = true
    preauthorized       = true
    # Looks like there's no need for this - better suited for k8s and other auto-scaling groups
    #   reusable            = true          
    recreate_if_invalid = "always"
    tags                = ["tag:toronto","tag:ts-ssh-enabled"]
    description         = "ext-toronto-droplet"
}

resource "tailscale_acl" "as_hujson" {
    overwrite_existing_content = true
    acl = templatefile("${path.module}/acl.hujson.tmlp",{
        routes = local.advertised_routes
    })
}