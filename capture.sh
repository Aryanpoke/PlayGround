#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)}"
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd -P)"
: "${CAPTURE_URL:?Set CAPTURE_URL to the exact preview URL.}"
: "${CAPTURE_DIR:?Set CAPTURE_DIR for screenshot evidence.}"
: "${RUNTIME_DIR:?RUNTIME_DIR must point to the worker runtime.}"

/usr/bin/time -p node -e "new URL(process.argv[1])" "$CAPTURE_URL" >/dev/null
/usr/bin/time -p mkdir -p "$CAPTURE_DIR"
CAPTURE_DIR="$(cd "$CAPTURE_DIR" && pwd -P)"
case "$CAPTURE_DIR/" in
  "$PROJECT_DIR"/*) echo 'CAPTURE_DIR must be outside PROJECT_DIR.' >&2; exit 1 ;;
esac
[[ -f "$RUNTIME_DIR/scripts/default-capture.mjs" ]] || { echo 'Capture runtime is unavailable.' >&2; exit 1; }

# The runtime capture opens CAPTURE_URL verbatim, waits for fonts and rendered content,
# saves desktop/mobile evidence, and closes the Chromium instance it launched.
CAPTURE_STRICT=1 CAPTURE_READY_SELECTOR=main \
  /usr/bin/time -p node "$RUNTIME_DIR/scripts/default-capture.mjs"
