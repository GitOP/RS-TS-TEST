
# Common tags and preferences for Tailscale nodes
locals {
    # List of routes we need to approve
    advertised_routes = [for s in var.subnets : s.cidr]
    subnet_tags = [for s in var.subnets : "tag:subnet-${replace(s.cidr, "/[./]/", "-")}"]

    # Logical tags used across ACLs and tailnet keys
    tailscale_acl_tags = merge(

        {
            infra          = "tag:infra"
            exitnode       = "tag:exitnode"
            appconnector   = "tag:appconnector"
            subnet_router  = "tag:subnet-router"
            ssh_enabled    = "tag:ts-ssh-enabled"
            tor1           = "tag:tor1"                     // region manually added for external_resource
        },
        { for s in var.subnets : s.name => "tag:${s.name}" }
    )
    

    # tags_subnet_router_1   = [for k in ["subnet_router", "newyork"] : local.tailscale_acl_tags[k]]
    tags_external_resource = [for k in ["ssh_enabled", "tor1"] : local.tailscale_acl_tags[k]]


    tailscale_preferences_external_resource = [
        "--auto-update", 
        "--ssh",
        "--accept-dns=false",
        "--accept-routes",
    ]
}

resource "tailscale_tailnet_key" "subnet_router_key" {
    for_each = { for s in var.subnets : s.name => s }

    ephemeral           = true
    preauthorized       = true
    # What is an ephemeral key with recreate=always?     
    # recreate_if_invalid = "always"
    
    tags                = [
                            "tag:subnet-router",
                            "tag:${each.key}",
                            "tag:subnet-${replace(each.value.cidr, "/[./]/", "-")}"
                            ]
    
    # How to prevent the key creation from running on every apply
    description         = "subnet-router"

    depends_on = [tailscale_acl.as_hujson]
}

resource "tailscale_tailnet_key" "external_resource" {
    ephemeral           = true
    preauthorized       = true   
    recreate_if_invalid = "always"
    tags                = local.tags_external_resource
    description         = "ext-toronto-droplet"

    depends_on = [tailscale_acl.as_hujson]
}

resource "tailscale_acl" "as_hujson" {
    overwrite_existing_content = true
    acl = templatefile("${path.module}/acl.hujson.tftpl",{
        routes = local.advertised_routes
        tags = values(local.tailscale_acl_tags)
    })
}