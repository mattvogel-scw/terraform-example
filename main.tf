terraform {
  backend "http" {
    address        = "http://localhost:8080/v1/state/demo/state"
    lock_address   = "http://localhost:8080/v1/state/demo/lock"
    unlock_address = "http://localhost:8080/v1/state/demo/lock"
    update_method  = "PUT"
    lock_method    = "POST"
    unlock_method  = "DELETE"
  }
}

locals {
  owners_hash = sha1(jsonencode(var.owners))
}

resource "null_resource" "suite_metadata" {
  triggers = {
    example        = var.example
    second_example = var.second_example
    environment    = var.environment
    owners_hash    = local.owners_hash
  }
}

resource "null_resource" "workload" {
  for_each = toset(var.workload_names)

  triggers = {
    name       = each.value
    env        = var.environment
    owner      = lookup(var.owners, each.value, "platform")
    test_token = var.force_replacement_token
  }
}

resource "null_resource" "replica" {
  count = var.instance_count

  triggers = {
    replica_number = tostring(count.index + 1)
    env            = var.environment
    workload       = var.workload_names[count.index % length(var.workload_names)]
    test_token     = var.force_replacement_token
  }
}

resource "terraform_data" "source" {
  input = "hello-from-source"
}

resource "terraform_data" "dependent" {
  input = "source id is ${terraform_data.source.id}"
}
