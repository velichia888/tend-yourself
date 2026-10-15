#!/usr/bin/env bash
# Inspect only existing Mac cert/key matches. No creation, revocation or upload.
set -euo pipefail
umask 077
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
RESULT="$ROOT/build/rainbow-macos-signing-probe/result.txt"
mkdir -p "$(dirname "$RESULT")"
if [ "${CM_BRANCH:-}" != "chore/rainbow-macos-signing-probe-20261014" ]; then
  echo "Wrong branch for Rainbow signing probe." >&2
  exit 2
fi
if [ -z "${CERTIFICATE_PRIVATE_KEY:-}" ]; then
  echo "Mac signing key: missing from Tend Yourself macos variable group." > "$RESULT"
  echo "Missing CERTIFICATE_PRIVATE_KEY in Tend's macos group." >&2
  exit 2
fi

# All downloaded signing materials are ephemeral. Never upload .p12 files.
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/rainbow-signing-probe.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT

inspect() {
  local kind="$1"
  shift
  mkdir -p "$SCRATCH/$kind"
  # --save creates only LOCAL signing containers; it does not issue Apple certs.
  # Both CLI output channels stay ephemeral to avoid accidental secret exposure.
  if app-store-connect certificates list \
      --type "$@" \
      --save \
      --certificates-dir "$SCRATCH/$kind" \
      >"$SCRATCH/$kind.stdout" 2>"$SCRATCH/$kind.stderr"; then
    if find "$SCRATCH/$kind" -type f \( -name '*.p12' -o -name '*.pfx' \) -print -quit | grep -q .; then
      return 0
    fi
    return 1
  fi
  return 2
}

APP_STATUS="unconfirmed"
if inspect app MAC_APP_DISTRIBUTION DISTRIBUTION; then
  APP_STATUS="matching identity available"
else
  case "$?" in
    1) APP_STATUS="no matching local signing container saved" ;;
    *) APP_STATUS="certificate query or conversion failed" ;;
  esac
fi

INSTALLER_STATUS="unconfirmed"
if inspect installer MAC_INSTALLER_DISTRIBUTION; then
  INSTALLER_STATUS="matching identity available"
else
  case "$?" in
    1) INSTALLER_STATUS="no matching local signing container saved" ;;
    *) INSTALLER_STATUS="certificate query or conversion failed" ;;
  esac
fi

{
  echo "Rainbow Mac signing probe (Tend Yourself CI)"
  echo "Apple Mac App Distribution: $APP_STATUS"
  echo "Apple Mac Installer Distribution: $INSTALLER_STATUS"
  echo "Apple certificate creation, revocation, and publishing: NONE"
  echo "Private keys and signing containers included in artifacts: NONE"
} > "$RESULT"
cat "$RESULT"

if [ "$APP_STATUS" != "matching identity available" ] || \
   [ "$INSTALLER_STATUS" != "matching identity available" ]; then
  echo "Not all Mac signing keys were confirmed. Do not change Tend certificates." >&2
  exit 3
fi
echo "Existing Mac keys confirmed. Rainbow packaging will require a separate workflow and approval."
