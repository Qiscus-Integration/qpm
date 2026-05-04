#!/bin/sh
#
# qpm CLI installer
#
# Usage:
#   sh -c "$(curl -fsSL https://project.qiscus.io/install.sh)"
#   sh -c "$(wget -qO- https://project.qiscus.io/install.sh)"
#
# Override defaults with env vars before running:
#   QPM_REPO=org/repo            (default: Qiscus-Integration/qpm)
#   QPM_INSTALL_DIR=/usr/local/bin
#
set -e

# --- colors (skip on non-tty) -------------------------------------------------
if [ -t 1 ]; then
  C_RESET=$(printf '\033[0m')
  C_BOLD=$(printf '\033[1m')
  C_DIM=$(printf '\033[2m')
  C_RED=$(printf '\033[31m')
  C_GREEN=$(printf '\033[32m')
  C_YELLOW=$(printf '\033[33m')
  C_BLUE=$(printf '\033[34m')
  C_CYAN=$(printf '\033[36m')
else
  C_RESET=; C_BOLD=; C_DIM=; C_RED=; C_GREEN=; C_YELLOW=; C_BLUE=; C_CYAN=
fi

info() { printf '%s\n' "${C_BLUE}->${C_RESET} $1"; }
ok()   { printf '%s\n' "${C_GREEN}OK${C_RESET} $1"; }
warn() { printf '%s\n' "${C_YELLOW}!${C_RESET}  $1"; }
err()  { printf '%s\n' "${C_RED}xx${C_RESET} $1" >&2; }

QPM_REPO="${QPM_REPO:-Qiscus-Integration/qpm}"
QPM_INSTALL_DIR="${QPM_INSTALL_DIR:-/usr/local/bin}"
QPM_SERVER="https://project.qiscus.io"

# --- banner -------------------------------------------------------------------
printf '\n'
printf '%s%s%s\n' "${C_CYAN}${C_BOLD}" "  qpm  Qiscus PM CLI installer" "${C_RESET}"
printf '%s%s%s\n' "${C_DIM}"            "  one curl  ·  OS-aware  ·  inspired by oh-my-zsh" "${C_RESET}"
printf '\n'

# --- detect OS / arch ---------------------------------------------------------
case "$(uname -s)" in
  Linux*)  OS="linux";  ASSET="qpm-linux"  ;;
  Darwin*) OS="macos";  ASSET="qpm-macos"  ;;
  *)
    err "Unsupported OS: $(uname -s)"
    err "qpm currently supports macOS and Linux."
    err "For Windows, run in PowerShell as Administrator:"
    err "  Invoke-WebRequest -Uri 'https://github.com/'"${QPM_REPO}"'/releases/latest/download/cli-win.exe' -OutFile 'C:\\Windows\\System32\\qpm.exe'"
    exit 1
    ;;
esac

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|amd64)   ARCH="x86_64" ;;
  arm64|aarch64)  ARCH="arm64"
                  warn "arm64 detected — current release ships x86_64 only; relying on Rosetta/binfmt." ;;
  *)              warn "Unrecognized arch '$ARCH' — proceeding anyway." ;;
esac

URL="https://github.com/${QPM_REPO}/releases/latest/download/${ASSET}"

printf "  %sOS:%s       %s (%s)\n"  "${C_BOLD}" "${C_RESET}" "$OS"   "$ARCH"
printf "  %sSource:%s   %s\n"        "${C_BOLD}" "${C_RESET}" "$URL"
printf "  %sInstall:%s  %s/qpm\n\n" "${C_BOLD}" "${C_RESET}" "$QPM_INSTALL_DIR"

# --- download -----------------------------------------------------------------
TMPFILE="$(mktemp)"
trap 'rm -f "$TMPFILE"' EXIT INT TERM

if command -v curl >/dev/null 2>&1; then
  info "Downloading with curl"
  if ! curl -fL --progress-bar "$URL" -o "$TMPFILE"; then
    err "Download failed."
    exit 1
  fi
elif command -v wget >/dev/null 2>&1; then
  info "Downloading with wget"
  if ! wget -q --show-progress "$URL" -O "$TMPFILE"; then
    err "Download failed."
    exit 1
  fi
else
  err "Need curl or wget. Install one and retry."
  exit 1
fi

if [ ! -s "$TMPFILE" ]; then
  err "Downloaded file is empty. Check the release at https://github.com/${QPM_REPO}/releases"
  exit 1
fi

chmod +x "$TMPFILE"

# --- install ------------------------------------------------------------------
TARGET="$QPM_INSTALL_DIR/qpm"

if [ ! -d "$QPM_INSTALL_DIR" ]; then
  info "Creating $QPM_INSTALL_DIR"
  if [ -w "$(dirname "$QPM_INSTALL_DIR")" ]; then
    mkdir -p "$QPM_INSTALL_DIR"
  else
    sudo mkdir -p "$QPM_INSTALL_DIR"
  fi
fi

info "Installing to $TARGET"
if [ -w "$QPM_INSTALL_DIR" ]; then
  mv "$TMPFILE" "$TARGET"
else
  warn "$QPM_INSTALL_DIR is not writable — using sudo."
  sudo mv "$TMPFILE" "$TARGET"
fi
trap - EXIT INT TERM

# --- post-install verification ------------------------------------------------
if ! command -v qpm >/dev/null 2>&1; then
  warn "qpm installed at $TARGET but is not on \$PATH."
  warn "Add this to your shell profile and reload (or open a new terminal):"
  warn "  export PATH=\"$QPM_INSTALL_DIR:\$PATH\""
fi

# --- seed server URL ----------------------------------------------------------
# So `qpm login` defaults to the server this installer came from. Skip if a
# config already exists — never clobber an existing token.
if [ ! -f "$HOME/.qpm/config.json" ]; then
  mkdir -p "$HOME/.qpm"
  printf '{\n  "server": "%s"\n}\n' "$QPM_SERVER" > "$HOME/.qpm/config.json"
  chmod 600 "$HOME/.qpm/config.json" 2>/dev/null || true
fi

# --- success ------------------------------------------------------------------
printf '\n'
ok "qpm installed!"
printf '\n'

printf '%sNext steps:%s\n' "${C_BOLD}" "${C_RESET}"
printf '  %s1.%s %sqpm login --server %s%s\n'   "${C_DIM}" "${C_RESET}" "${C_BOLD}" "$QPM_SERVER" "${C_RESET}"
printf '       %s# sign in with Google; token saved to ~/.qpm/config.json%s\n' "${C_DIM}" "${C_RESET}"
printf '  %s2.%s %sqpm whoami%s\n'              "${C_DIM}" "${C_RESET}" "${C_BOLD}" "${C_RESET}"
printf '       %s# verify identity & role%s\n'  "${C_DIM}" "${C_RESET}"
printf '  %s3.%s %sqpm tools%s\n'               "${C_DIM}" "${C_RESET}" "${C_BOLD}" "${C_RESET}"
printf '       %s# list role-scoped commands%s\n' "${C_DIM}" "${C_RESET}"
printf '  %s4.%s %sqpm project list%s\n'        "${C_DIM}" "${C_RESET}" "${C_BOLD}" "${C_RESET}"
printf '       %s# your first command — try it!%s\n\n' "${C_DIM}" "${C_RESET}"

printf '%sTip:%s skip flags on any command to use interactive mode — the CLI will prompt you.\n\n' "${C_BOLD}" "${C_RESET}"

printf '  %sHelp:%s    qpm --help    qpm <resource> <verb> --help\n' "${C_BOLD}" "${C_RESET}"
printf '  %sLogout:%s  qpm logout\n'                                  "${C_BOLD}" "${C_RESET}"
printf '  %sSource:%s  https://github.com/%s\n\n'                    "${C_BOLD}" "${C_RESET}" "$QPM_REPO"
