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

## Workflow helper scripts

Two helper scripts are available in `scripts/`:

- `scripts/pre-workflow.sh`
- `scripts/post-workflow.sh`

Make sure they are executable:

```bash
chmod +x scripts/pre-workflow.sh scripts/post-workflow.sh
```

### Pre-workflow script

Run:

```bash
./scripts/pre-workflow.sh
```

What it does:

- Verifies `terraform` is installed
- Optionally checks a local API health endpoint
- Runs `terraform fmt -check -diff -recursive`
- Runs `terraform init -input=false`
- Runs `terraform validate`
- Optionally writes a plan file

Optional environment variables:

- `WORK_DIR`: Terraform working directory (default: repository root)
- `REQUIRE_LOCAL_API=1`: enable API health check
- `API_URL=http://localhost:8080/healthz`: health check URL
- `PLAN_OUTPUT_FILE=tfplan`: output path for `terraform plan -out`

Example:

```bash
REQUIRE_LOCAL_API=1 API_URL=http://localhost:8080/healthz PLAN_OUTPUT_FILE=tfplan ./scripts/pre-workflow.sh
```

### Post-workflow script

Run:

```bash
./scripts/post-workflow.sh
```

What it does:

- Optionally shows Terraform outputs
- Optionally shows Terraform state list
- Optionally destroys infrastructure
- Optionally removes the plan file created in pre-workflow

Optional environment variables:

- `WORK_DIR`: Terraform working directory (default: repository root)
- `SHOW_OUTPUTS=1`: run `terraform output`
- `SHOW_STATE_LIST=1`: run `terraform state list`
- `DESTROY_ON_EXIT=1`: run `terraform destroy -auto-approve -input=false`
- `PLAN_OUTPUT_FILE=tfplan`: plan file path to consider for cleanup
- `CLEAN_PLAN_FILE=1`: remove `PLAN_OUTPUT_FILE` if it exists

Example:

```bash
SHOW_OUTPUTS=1 SHOW_STATE_LIST=1 PLAN_OUTPUT_FILE=tfplan CLEAN_PLAN_FILE=1 ./scripts/post-workflow.sh
```

## What this test exercises

- Backend state read/write and ETag checks (`GET`/`PUT`)
- Lock acquisition and release (`POST`/`DELETE`)
- Creation of multiple resource shapes (single, `for_each`, and `count`)
- Rendering a template from generated secrets (`random_password` + `tls_private_key`)
- Stable outputs plus a fingerprint value to quickly verify state changes

## Template example

This module now renders `templates/generated_credentials.tftpl` using:
- a generated random password (`random_password.app_secret.result`)
- a generated TLS public key (`tls_private_key.app.public_key_pem`)

The rendered value is available as the sensitive output `rendered_credentials_template`.

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
