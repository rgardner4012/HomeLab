#!/usr/bin/env bash
# nas-deploy.sh — Deploy one or more Docker Compose stacks on the NAS.
#
# Usage:
#   nas-deploy.sh <stack1> [stack2] ...   deploy only the specified stacks
#   nas-deploy.sh                         deploy all stacks (fallback)
#
# Stacks are directories under DOCKER_ROOT that contain a docker-compose.yaml.
# The script only restarts a container if its service definition changed
# (docker compose up -d is idempotent by design).
set -euo pipefail

DOCKER_ROOT="/volume3/docker"

log() {
  echo "[$(date -Iseconds)] $*"
}

deploy_stack() {
  local stack_dir="$1"
  local stack_name
  stack_name="$(basename "$stack_dir")"

  if [[ ! -f "$stack_dir/docker-compose.yaml" ]]; then
    log "SKIP $stack_name — no docker-compose.yaml found"
    return 0
  fi

  log "Deploying $stack_name ..."

  local env_flag=()
  if [[ -f "$stack_dir/.env" ]]; then
    env_flag=(--env-file "$stack_dir/.env")
  fi

  docker compose \
    --project-name "$stack_name" \
    --file "$stack_dir/docker-compose.yaml" \
    "${env_flag[@]}" \
    up --detach --remove-orphans

  log "Done $stack_name"
}

log "Starting NAS deploy from $DOCKER_ROOT"

if [[ $# -gt 0 ]]; then
  # Deploy only the stacks passed as arguments
  for stack in "$@"; do
    deploy_stack "$DOCKER_ROOT/$stack"
  done
else
  # Fallback: deploy all stacks
  log "No stacks specified — deploying all"
  for stack_dir in "$DOCKER_ROOT"/*/; do
    [[ "$(basename "$stack_dir")" == "scripts" ]] && continue
    deploy_stack "$stack_dir"
  done
fi

log "NAS deploy complete"
