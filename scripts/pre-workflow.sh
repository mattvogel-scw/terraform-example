#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="${WORK_DIR:-$ROOT_DIR}"

log() {
  printf '[pre-workflow] %s\n' "$*"
}

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log "Missing required command: $cmd"
    exit 1
  fi
}

log "Starting pre-workflow checks"

require_cmd terraform

if [[ -n "${REQUIRE_LOCAL_API:-}" ]]; then
  require_cmd curl
  API_URL="${API_URL:-http://localhost:8080/healthz}"
  log "Checking local API at $API_URL"
  curl --fail --silent --show-error "$API_URL" >/dev/null
fi

log "Running terraform format check"
terraform -chdir="$WORK_DIR" fmt -check -diff -recursive

log "Initializing terraform"
terraform -chdir="$WORK_DIR" init -input=false

log "Validating terraform configuration"
terraform -chdir="$WORK_DIR" validate

if [[ -n "${PLAN_OUTPUT_FILE:-}" ]]; then
  log "Writing terraform plan to ${PLAN_OUTPUT_FILE}"
  terraform -chdir="$WORK_DIR" plan -input=false -out="$PLAN_OUTPUT_FILE"
fi

log "Pre-workflow completed"
