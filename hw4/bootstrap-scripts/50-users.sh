#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  40-users.sh <user> [group] [-u UID] [-g GID] [--no-sudo]

Examples:
  ./40-users.sh devops
  ./40-users.sh devops devops
  ./40-users.sh devops -u 2000 -g 2000
  ./40-users.sh devops devops --no-sudo

Notes:
  - If [group] is omitted, group=user.
  - If UID/GID not provided, they will be auto-selected (next free >= 2000).
EOF
}

# --- Parse args (simple & robust enough) ---
if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

USER_NAME=""
GROUP_NAME=""
USER_UID=""
GROUP_GID=""
ADD_SUDO=1

# First positional: user
USER_NAME="${1:-}"
shift

# Second positional (optional): group (only if it doesn't look like an option)
if [[ $# -gt 0 && "${1:-}" != -* ]]; then
  GROUP_NAME="$1"
  shift
else
  GROUP_NAME="$USER_NAME"
fi

# Options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--uid)
      USER_UID="${2:-}"; shift 2 ;;
    -g|--gid)
      GROUP_GID="${2:-}"; shift 2 ;;
    --no-sudo)
      ADD_SUDO=0; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1 ;;
  esac
done

# --- Basic validation (avoid weird names) ---
name_re='^[a-z_][a-z0-9_-]*$'
if ! [[ "$USER_NAME" =~ $name_re ]]; then
  echo "Invalid user name: $USER_NAME" >&2
  exit 1
fi
if ! [[ "$GROUP_NAME" =~ $name_re ]]; then
  echo "Invalid group name: $GROUP_NAME" >&2
  exit 1
fi

is_uint() { [[ "${1:-}" =~ ^[0-9]+$ ]]; }
if [[ -n "$USER_UID" ]] && ! is_uint "$USER_UID"; then
  echo "Invalid UID: $USER_UID" >&2
  exit 1
fi
if [[ -n "$GROUP_GID" ]] && ! is_uint "$GROUP_GID"; then
  echo "Invalid GID: $GROUP_GID" >&2
  exit 1
fi

# --- Helpers to pick free IDs ---
next_free_gid() {
  local start="${1:-2000}" gid="$start"
  while getent group "$gid" >/dev/null; do gid=$((gid+1)); done
  echo "$gid"
}
next_free_uid() {
  local start="${1:-2000}" uid="$start"
  while getent passwd "$uid" >/dev/null; do uid=$((uid+1)); done
  echo "$uid"
}

# --- Resolve UID/GID defaults ---
if [[ -z "$GROUP_GID" ]]; then
  if getent group "$GROUP_NAME" >/dev/null; then
    GROUP_GID="$(getent group "$GROUP_NAME" | awk -F: '{print $3}')"
  else
    GROUP_GID="$(next_free_gid 2000)"
  fi
fi

if [[ -z "$USER_UID" ]]; then
  if id "$USER_NAME" >/dev/null 2>&1; then
    USER_UID="$(id -u "$USER_NAME")"
  else
    USER_UID="$(next_free_uid 2000)"
  fi
fi

# --- Create group (idempotent) ---
if getent group "$GROUP_NAME" >/dev/null; then
  existing_gid="$(getent group "$GROUP_NAME" | awk -F: '{print $3}')"
  if [[ "$existing_gid" != "$GROUP_GID" ]]; then
    echo "ERROR: Group '$GROUP_NAME' exists with GID=$existing_gid, requested GID=$GROUP_GID" >&2
    echo "Tip: omit -g/--gid to reuse existing GID, or choose another GID." >&2
    exit 1
  fi
else
  sudo groupadd -g "$GROUP_GID" "$GROUP_NAME"
fi

# --- Create user (idempotent) ---
if id "$USER_NAME" >/dev/null 2>&1; then
  existing_uid="$(id -u "$USER_NAME")"
  existing_gid="$(id -g "$USER_NAME")"
  if [[ "$existing_uid" != "$USER_UID" ]]; then
    echo "ERROR: User '$USER_NAME' exists with UID=$existing_uid, requested UID=$USER_UID" >&2
    echo "Tip: omit -u/--uid to reuse existing UID, or choose another UID." >&2
    exit 1
  fi
  if [[ "$existing_gid" != "$GROUP_GID" ]]; then
    echo "WARN: User '$USER_NAME' exists but primary GID=$existing_gid (requested $GROUP_GID)." >&2
    echo "      You can change it with: sudo usermod -g $GROUP_NAME $USER_NAME" >&2
  fi
else
  sudo useradd -m -u "$USER_UID" -g "$GROUP_NAME" -s /bin/bash "$USER_NAME"
fi

# --- Optional sudo ---
if [[ "$ADD_SUDO" -eq 1 ]]; then
  # On Debian/Ubuntu the admin group is 'sudo'; on RHEL it may be 'wheel'
  if getent group sudo >/dev/null; then
    sudo usermod -aG sudo "$USER_NAME"
  elif getent group wheel >/dev/null; then
    sudo usermod -aG wheel "$USER_NAME"
  else
    echo "WARN: No 'sudo' or 'wheel' group found; skipped sudo access." >&2
  fi
fi

echo "✅ Ensured user/group: $USER_NAME(UID=$USER_UID) : $GROUP_NAME(GID=$GROUP_GID)  sudo=$ADD_SUDO"
