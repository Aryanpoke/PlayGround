#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

run_timed() {
  /usr/bin/time -p "$@"
}

: "${RUNTIME_DIR:?RUNTIME_DIR must point to the OpenCode runtime}"
: "${CAPTURE_URL:?Set CAPTURE_URL to the exact preview URL}"
: "${CAPTURE_DIR:?Set CAPTURE_DIR to the evidence output directory}"
export CAPTURE_READY_SELECTOR="${CAPTURE_READY_SELECTOR:-main[data-app-ready='true']}"
run_timed node "$RUNTIME_DIR/scripts/default-capture.mjs"
