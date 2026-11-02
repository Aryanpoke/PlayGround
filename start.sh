#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
export PROJECT_DIR
cd "$PROJECT_DIR"

run_timed() {
  /usr/bin/time -p "$@"
}

: "${OPENCODE_WEB_DIR:?OPENCODE_WEB_DIR must point to worker metadata storage}"
PORT="${PORT:-3000}"
export PORT

run_timed npm install --no-audit --no-fund --ignore-scripts
run_timed npm run build
run_timed node -e 'const fs=require("node:fs"); const path=require("node:path"); const project=path.resolve(process.env.PROJECT_DIR); const directory=path.resolve(project,"dist"); if (!directory.startsWith(project+path.sep)) throw new Error("Build directory must be inside project"); fs.mkdirSync(process.env.OPENCODE_WEB_DIR,{recursive:true}); fs.writeFileSync(path.join(process.env.OPENCODE_WEB_DIR,"deployment-output.json"),JSON.stringify({project,directory}));'
run_timed node server.mjs
