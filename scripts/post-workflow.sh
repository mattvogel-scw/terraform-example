#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="${WORK_DIR:-$ROOT_DIR}"

log() {
  printf '[post-workflow] %s\n' "$*"
}

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log "Missing required command: $cmd"
    exit 1
  fi
}

log "Starting post-workflow tasks"
require_cmd terraform

if [[ -n "${SHOW_OUTPUTS:-}" ]]; then
  log "Showing terraform outputs"
  terraform -chdir="$WORK_DIR" output
fi

if [[ -n "${SHOW_STATE_LIST:-}" ]]; then
  log "Showing terraform state list"
  terraform -chdir="$WORK_DIR" state list || true
fi

if [[ -n "${DESTROY_ON_EXIT:-}" ]]; then
  log "Destroying infrastructure"
  terraform -chdir="$WORK_DIR" destroy -auto-approve -input=false
fi

if [[ -n "${PLAN_OUTPUT_FILE:-}" && -f "${PLAN_OUTPUT_FILE}" ]]; then
  if [[ -n "${CLEAN_PLAN_FILE:-}" ]]; then
    log "Removing plan file ${PLAN_OUTPUT_FILE}"
    rm -f "${PLAN_OUTPUT_FILE}"
  fi
fi

log "Post-workflow completed"
