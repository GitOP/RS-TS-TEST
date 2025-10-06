
# Common tags and preferences for Tailscale nodes
locals {
    # List of routes we need to approve
    advertised_routes = [local.subnet_cidr]
    subnet_tags = [for r in local.advertised_routes : "tag:subnet-${replace(r, "/[./]/", "-")}"]

    # Logical tags used across ACLs and tailnet keys
    tailscale_acl_tags = {
        infra          = "tag:infra"
        exitnode       = "tag:exitnode"
        appconnector   = "tag:appconnector"
        subnet_router  = "tag:subnet-router"
        ssh_enabled    = "tag:ts-ssh-enabled"
        toronto        = "tag:toronto"
        newyork        = "tag:newyork"
    }

    tags_subnet_router_1   = [for k in ["infra", "subnet_router", "newyork"] : local.tailscale_acl_tags[k]]
    tags_external_resource = [for k in ["infra", "ssh_enabled", "toronto"] : local.tailscale_acl_tags[k]]

    # CLI preferences commonly used during tailscale up
    tailscale_set_preferences = [
        # Seems to be deprecated from up, now only supported with set? 
        # "--auto-update", 
        "--ssh",
        "--accept-dns=false",
    ]
}

resource "tailscale_tailnet_key" "subnet_router_1" {
    ephemeral           = true
    preauthorized       = true
    # Looks like there's no need for this - better suited for k8s and other scaling groups
    #   reusable            = true          
    recreate_if_invalid = "always"
    tags                = concat(local.subnet_tags,
                                local.tags_subnet_router_1)
    description         = "subnet-router"

    depends_on = [tailscale_acl.as_hujson]
}

resource "tailscale_tailnet_key" "external_resource" {
    ephemeral           = true
    preauthorized       = true
    # Looks like there's no need for this - better suited for k8s and other auto-scaling groups
    #   reusable            = true          
    recreate_if_invalid = "always"
    tags                = local.tags_external_resource
    description         = "ext-toronto-droplet"

    depends_on = [tailscale_acl.as_hujson]
}

resource "tailscale_acl" "as_hujson" {
    overwrite_existing_content = true
    acl = templatefile("${path.module}/acl.hujson.tmlp",{
        routes = local.advertised_routes
        tags = values(local.tailscale_acl_tags)
    })
}