# Terraform HTTP backend — local E2E demo

This example uses Terraform's built-in HTTP backend to talk to the local API. It intentionally uses plain HTTP (no TLS) for local demo only.

Paths configured in backend:
- address: http://localhost:8080/v1/state/demo/state
- lock_address: http://localhost:8080/v1/state/demo/lock
- unlock_address: http://localhost:8080/v1/state/demo/lock
- update_method: PUT
- lock_method: POST
- unlock_method: DELETE

Prerequisites:
- Go
- Terraform CLI

Run end-to-end (starts API, runs init/plan, stops API):
- make e2e (from repo root [Makefile](Makefile))

Manual run:
- In a first terminal:
  - make run-api (from repo root)
- In a second terminal:
  - cd [examples/terraform-http-backend](examples/terraform-http-backend)
  - terraform init -input=false
  - terraform plan -input=false
- Stop the API with Ctrl+C in the first terminal.

What this exercises:
- GET/PUT of state with ETag handling
- POST/DELETE lock lifecycle
- In-memory storage only; data is not persisted between runs