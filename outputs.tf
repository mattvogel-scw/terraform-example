output "suite_metadata_id" {
  value = null_resource.suite_metadata.id
}

output "workload_ids" {
  value = {
    for name, resource in null_resource.workload :
    name => resource.id
  }
}

output "replica_ids" {
  value = [
    for resource in null_resource.replica :
    resource.id
  ]
}

output "state_test_fingerprint" {
  value = sha1(jsonencode({
    metadata = null_resource.suite_metadata.id
    workload = {
      for name, resource in null_resource.workload :
      name => resource.id
    }
    replica = [
      for resource in null_resource.replica :
      resource.id
    ]
  }))
}
