#!/usr/bin/env bash
# Convenience launcher for running the Flutter app on a physical phone
# (iOS or Android) against the Spring Boot backend running on this Mac.
#
# Physical devices cannot reach the Mac through `localhost` or
# `10.0.2.2`. This script offers two routes:
#
#   Reverse mode (--reverse): runs `adb reverse tcp:<port> tcp:<port>`
#   for the attached Android device, then launches pointed at
#   `http://localhost:<port>`. Works over USB with or without Wi-Fi and
#   is immune to the Mac's IP changing — the recommended path for a
#   physical Android.
#
#   LAN mode (default): picks the Mac's current Wi-Fi IP and passes it
#   as `--dart-define=API_BASE_URL=http://<mac-lan-ip>:<port>`. Needed
#   for a physical iOS device (which has no adb reverse). Requires the
#   phone and Mac on the same Wi-Fi and the phone not blocking the
#   app's local-network access.
#
# Usage:
#   scripts/run_physical.sh --reverse          # Android USB tunnel (recommended)
#   scripts/run_physical.sh                     # LAN mode, auto IP, port 8080
#   scripts/run_physical.sh --host 10.5.5.188   # LAN mode, explicit host
#   scripts/run_physical.sh --port 9090         # custom port
#   scripts/run_physical.sh print               # print the resolved URL only
#   scripts/run_physical.sh --reverse -- -d <id>  # forward -d <id> to flutter run
#
# Compatible with the stock macOS bash 3.2. Arguments after `--` are
# forwarded to `flutter run` verbatim.
set -eo pipefail

PORT=8080
HOST=""
MODE="lan"
PRINT_ONLY=false
EXTRA_ARGS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --port) PORT="$2"; shift 2 ;;
    --host) HOST="$2"; shift 2 ;;
    --reverse) MODE="reverse"; shift ;;
    print) PRINT_ONLY=true; shift ;;
    --) shift; while [ $# -gt 0 ]; do EXTRA_ARGS[${#EXTRA_ARGS[@]}]="$1"; shift; done; break ;;
    *) EXTRA_ARGS[${#EXTRA_ARGS[@]}]="$1"; shift ;;
  esac
done

ADB="adb"
command -v adb >/dev/null 2>&1 || ADB="$HOME/Library/Android/sdk/platform-tools/adb"

if [ "$MODE" = "reverse" ]; then
  HOST="localhost"
  if ! command -v "$ADB" >/dev/null 2>&1 && [ ! -x "$ADB" ]; then
    echo "adb not found. Add Android platform-tools to PATH and retry." >&2
    exit 1
  fi
  # Prefer a physical device (serial not starting with 'emulator-').
  TARGET=""
  while read -r SERIAL STATE; do
    [ "$STATE" = "device" ] || continue
    case "$SERIAL" in
      emulator-*) [ -z "$TARGET" ] && TARGET="$SERIAL" ;;  # fallback only
      *) TARGET="$SERIAL"; break ;;
    esac
  done <<EOF
$("$ADB" devices | sed '1d')
EOF
  if [ -z "$TARGET" ]; then
    echo "No Android device in 'adb devices'. Plug in the phone and enable USB debugging." >&2
    exit 1
  fi
  echo "adb reverse tcp:$PORT tcp:$PORT (on $TARGET)"
  "$ADB" -s "$TARGET" reverse "tcp:$PORT" "tcp:$PORT" >/dev/null
  # Target this device explicitly so flutter doesn't prompt among several.
  EXTRA_ARGS[${#EXTRA_ARGS[@]}]="-d"
  EXTRA_ARGS[${#EXTRA_ARGS[@]}]="$TARGET"
elif [ -z "$HOST" ]; then
  for IF in en0 en1 en2 en3; do
    IP=$(ipconfig getifaddr "$IF" 2>/dev/null || true)
    if [ -n "$IP" ]; then HOST="$IP"; break; fi
  done
fi

if [ -z "$HOST" ]; then
  echo "Could not detect a LAN IP on this Mac. Pass --host <ip> explicitly." >&2
  exit 1
fi

API_BASE_URL="http://${HOST}:${PORT}"

if [ "$PRINT_ONLY" = true ]; then
  echo "$API_BASE_URL"
  exit 0
fi

# Load the rest of the local config from .env when present. The explicit
# --dart-define below comes later, so it overrides API_BASE_URL there.
ENV_FILE="$(cd "$(dirname "$0")/.." && pwd)/.env"
if [ -f "$ENV_FILE" ]; then
  EXTRA_ARGS[${#EXTRA_ARGS[@]}]="--dart-define-from-file=$ENV_FILE"
fi

echo "Launching Flutter with API_BASE_URL=$API_BASE_URL"
# ${arr[@]+"${arr[@]}"} expands safely even when the array is empty
# under older bash; avoids the "unbound variable" error.
exec flutter run --dart-define="API_BASE_URL=${API_BASE_URL}" ${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}
