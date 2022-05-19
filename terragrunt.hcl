locals {
  credentials = read_terragrunt_config(find_in_parent_folders("credentials.hcl"))
  server      = read_terragrunt_config(find_in_parent_folders("server.hcl"))
}

# Generite file with provider`s (vSphere) data
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "vsphere" {
  user           = "${local.credentials.locals.user}"
  password       = "${local.credentials.locals.password}"
  vsphere_server = "${local.server.locals.address}"
  allow_unverified_ssl = true
}
EOF
}