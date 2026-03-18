# Terraform HTTP backend local test

This example uses Terraform's built-in HTTP backend to talk to a local API.
It intentionally uses plain HTTP (no TLS) for local testing only.

Configured backend endpoints:
- `address`: `http://localhost:8080/v1/state/demo/state`
- `lock_address`: `http://localhost:8080/v1/state/demo/lock`
- `unlock_address`: `http://localhost:8080/v1/state/demo/lock`
- `update_method`: `PUT`
- `lock_method`: `POST`
- `unlock_method`: `DELETE`

## Prerequisites

- Go
- Terraform CLI (`>= 1.4`)

## Run end-to-end

From the repository root:
- `make e2e`

That target starts the API, runs Terraform, and stops the API.

## Manual run

In a first terminal (from repository root):
- `make run-api`

In a second terminal (this directory):
- `terraform init -input=false`
- `terraform plan -input=false`
- `terraform apply -auto-approve -input=false`
- `terraform destroy -auto-approve -input=false`

Stop the API with `Ctrl+C` in the first terminal.

## What this test exercises

- Backend state read/write and ETag checks (`GET`/`PUT`)
- Lock acquisition and release (`POST`/`DELETE`)
- Creation of multiple resource shapes (single, `for_each`, and `count`)
- Stable outputs plus a fingerprint value to quickly verify state changes

## Useful knobs

- `instance_count`: controls number of counted resources (default `3`)
- `workload_names`: controls for-each resources (default `api,worker,scheduler`)
- `force_replacement_token`: set a new string to force resource recreation

Example:

```bash
terraform apply -auto-approve \
  -var='environment=ci' \
  -var='instance_count=5' \
  -var='force_replacement_token=run-001'
```
