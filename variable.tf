variable "example" {
  type    = string
  default = "demo"
}

variable "second_example" {
  type    = string
  default = "test"
}

variable "environment" {
  type    = string
  default = "local"
}

variable "workload_names" {
  type    = list(string)
  default = ["api", "worker", "scheduler"]
}

variable "owners" {
  type = map(string)
  default = {
    api       = "platform"
    worker    = "batch"
    scheduler = "platform"
  }
}

variable "instance_count" {
  type    = number
  default = 3

  validation {
    condition     = var.instance_count > 0
    error_message = "instance_count must be greater than zero."
  }
}

variable "force_replacement_token" {
  type    = string
  default = ""
}
