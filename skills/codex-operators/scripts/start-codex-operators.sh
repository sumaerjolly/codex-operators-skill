#!/usr/bin/env bash
set -euo pipefail

APP_REPO_URL="${CODEX_OPERATORS_APP_REPO:-https://github.com/sumaerjolly/codex-operators-interactive.git}"
APP_DIR_NAME="${CODEX_OPERATORS_APP_DIR_NAME:-codex-operators-interactive}"
APP_PARENT="${CODEX_OPERATORS_PARENT:-$HOME/Desktop/fun-projects}"
FIELD_KIT="${CODEX_OPERATORS_FIELD_KIT:-$HOME/Desktop/Codex Operators Field Kit}"
LOG_DIR="${CODEX_OPERATORS_LOG_DIR:-$HOME/.codex-operators}"
NO_START=0
RESET=0
SERVER_URL=""

for arg in "$@"; do
  case "$arg" in
    --no-start)
      NO_START=1
      ;;
    --reset)
      RESET=1
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 2
      ;;
  esac
done

is_trainer_repo() {
  local dir="$1"
  [[ -f "$dir/package.json" && -d "$dir/missions" && -d "$dir/checkers" ]] || return 1
  grep -q '"name"[[:space:]]*:[[:space:]]*"codex-operators"' "$dir/package.json"
}

use_modern_node() {
  local candidate_dirs=()
  local dir major

  if [[ -n "${CODEX_OPERATORS_NODE_BIN:-}" ]]; then
    candidate_dirs+=("$(dirname "$CODEX_OPERATORS_NODE_BIN")")
  fi

  candidate_dirs+=(
    "$HOME/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin"
    "/opt/homebrew/bin"
    "/usr/local/bin"
  )

  for dir in "${candidate_dirs[@]}"; do
    if [[ -x "$dir/node" ]]; then
      major="$("$dir/node" -p "Number(process.versions.node.split('.')[0])" 2>/dev/null || echo 0)"
      if [[ "$major" -ge 18 ]]; then
        export PATH="$dir:$PATH"
        hash -r
        return 0
      fi
    fi
  done

  if command -v node >/dev/null 2>&1; then
    major="$(node -p "Number(process.versions.node.split('.')[0])" 2>/dev/null || echo 0)"
    if [[ "$major" -ge 18 ]]; then
      return 0
    fi
  fi

  echo "Codex Operators needs Node.js 18 or newer to start the local mission app." >&2
  echo "Install a current Node.js version, or set CODEX_OPERATORS_NODE_BIN to a modern node executable." >&2
  return 1
}

find_trainer_repo() {
  local candidates=()
  local dir

  if [[ -n "${CODEX_OPERATORS_APP_PATH:-}" ]]; then
    candidates+=("$CODEX_OPERATORS_APP_PATH")
  fi

  dir="$(pwd)"
  while [[ "$dir" != "/" ]]; do
    candidates+=("$dir")
    dir="$(dirname "$dir")"
  done

  candidates+=(
    "$APP_PARENT/$APP_DIR_NAME"
    "$APP_PARENT/codex-interactive"
    "$HOME/Desktop/fun-projects/codex-operators-interactive"
    "$HOME/Desktop/fun-projects/codex-interactive"
    "$HOME/Documents/codex-operators-interactive"
    "$HOME/Desktop/codex-operators-interactive"
  )

  for dir in "${candidates[@]}"; do
    if [[ -d "$dir" ]] && is_trainer_repo "$dir"; then
      printf '%s\n' "$dir"
      return 0
    fi
  done

  return 1
}

find_running_url() {
  local port
  for port in $(seq 3000 3010); do
    if curl -fsS "http://localhost:$port/api/missions" >/dev/null 2>&1; then
      printf 'http://localhost:%s\n' "$port"
      return 0
    fi
  done
  return 1
}

trainer_url() {
  local base="$1"
  if [[ "$RESET" -eq 1 ]]; then
    printf '%s/?reset=1&trainer=1\n' "${base%/}"
    return 0
  fi
  printf '%s/?trainer=1\n' "${base%/}"
}

prepare_field_kit() {
  local dirs=(
    "$FIELD_KIT"
    "$FIELD_KIT/Proof"
    "$FIELD_KIT/Receipts"
    "$FIELD_KIT/Connector Demos"
    "$FIELD_KIT/Outputs"
    "$FIELD_KIT/Skills"
    "$FIELD_KIT/Automations"
  )

  if [[ "$RESET" -eq 1 ]]; then
    rm -rf "$FIELD_KIT/Proof" "$FIELD_KIT/Outputs" "$FIELD_KIT/Skills" "$FIELD_KIT/Automations"
  fi

  mkdir -p "${dirs[@]}"

  if [[ ! -f "$FIELD_KIT/START-HERE.md" ]]; then
    cat > "$FIELD_KIT/START-HERE.md" <<'MARKDOWN'
# Codex Operators Field Kit

This folder is your local practice workspace for Codex Operators.

- The browser mission screen tells you what to do next.
- Codex chat does the actual work.
- Proof files appear here so you can inspect what Codex created.

The main lesson: ChatGPT answers in chat. Codex can operate on local files.
MARKDOWN
  fi

  if [[ ! -f "$FIELD_KIT/Proof/README.md" ]]; then
    cat > "$FIELD_KIT/Proof/README.md" <<'MARKDOWN'
# Proof

Mission proof files go here when the lesson asks Codex to create something on your Desktop.

Open these files in Codex and in Finder. The point is to verify real local work, not just read a chat reply.
MARKDOWN
  fi
}

install_dependencies() {
  local app_dir="$1"
  if [[ ! -d "$app_dir/node_modules" ]]; then
    (cd "$app_dir" && npm install)
  fi
}

start_server() {
  local app_dir="$1"
  local log_file="$LOG_DIR/server.log"
  mkdir -p "$LOG_DIR"
  : > "$log_file"

  (cd "$app_dir" && nohup npm run dev </dev/null > "$log_file" 2>&1 &)

  local attempt
  for attempt in $(seq 1 60); do
    if grep -Eo 'http://localhost:[0-9]+' "$log_file" | tail -1 >/tmp/codex-operators-url.$$; then
      local url
      url="$(cat /tmp/codex-operators-url.$$)"
      rm -f /tmp/codex-operators-url.$$
      SERVER_URL="$url"
      return 0
    fi
    sleep 0.5
  done

  echo "Could not detect the Codex Operators URL. Server log: $log_file" >&2
  return 1
}

main() {
  local app_dir
  if ! app_dir="$(find_trainer_repo)"; then
    mkdir -p "$APP_PARENT"
    git clone "$APP_REPO_URL" "$APP_PARENT/$APP_DIR_NAME"
    app_dir="$APP_PARENT/$APP_DIR_NAME"
  fi

  use_modern_node
  prepare_field_kit
  install_dependencies "$app_dir"

  if [[ "$NO_START" -eq 1 ]]; then
    echo "Codex Operators app: $app_dir"
    echo "Desktop Field Kit: $FIELD_KIT"
    echo "Server not started because --no-start was used."
    return 0
  fi

  local url
  if url="$(find_running_url)"; then
    echo "Codex Operators app: $app_dir"
    echo "Desktop Field Kit: $FIELD_KIT"
    echo "Mission screen: $(trainer_url "$url")"
    return 0
  fi

  start_server "$app_dir"
  url="$SERVER_URL"
  echo "Codex Operators app: $app_dir"
  echo "Desktop Field Kit: $FIELD_KIT"
  echo "Mission screen: $(trainer_url "$url")"
}

main
