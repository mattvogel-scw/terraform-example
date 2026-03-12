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

resource "null_resource" "demo" {
  triggers = {
    timestamp = timestamp()
  }
}