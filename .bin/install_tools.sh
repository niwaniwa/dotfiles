#!/usr/bin/env bash
# Idempotent installer for CLI tools used by this dotfiles setup.
# Keeps tool provisioning separate from config (.bashrc) — re-running is safe.
set -ue

info() { command echo -e "\e[1;34m[install_tools]\e[m $*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# Run privileged commands with sudo only when needed/available.
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
elif have sudo; then
  SUDO="sudo"
else
  SUDO=""
fi

# --- Claude Code -----------------------------------------------------------
if have claude; then
  info "claude already installed: $(command -v claude) (skip)"
elif have curl; then
  info "installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
else
  info "curl not found, skipping Claude Code"
fi

# --- fzf -------------------------------------------------------------------
# apt's fzf (0.44) lacks `--bash`; use git for the latest + ~/.fzf.bash.
if ! have git; then
  info "git not found, skipping fzf"
else
  if [ -d "$HOME/.fzf" ]; then
    info "fzf already cloned, updating..."
    git -C "$HOME/.fzf" pull --ff-only || true
  else
    info "installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  fi
  "$HOME/.fzf/install" --key-bindings --completion --no-update-rc
fi

# --- apt tools: fd / bat / zoxide / eza / ripgrep --------------------------
# Ubuntu binary names: fd-find -> fdfind, bat -> batcat (aliased in .bashrc).
apt_pkgs=(fd-find bat zoxide eza ripgrep)
missing=()
for cmd in fdfind batcat zoxide eza rg; do
  have "$cmd" || missing+=("$cmd")
done
if [ ${#missing[@]} -eq 0 ]; then
  info "apt tools already installed (skip apt)"
elif ! have apt-get; then
  info "apt-get not found, skipping ${apt_pkgs[*]} (missing: ${missing[*]})"
else
  info "installing via apt: ${apt_pkgs[*]} (missing: ${missing[*]})"
  $SUDO apt-get update -qq
  $SUDO apt-get install -y "${apt_pkgs[@]}"
fi

# --- lazygit ---------------------------------------------------------------
# Not in Ubuntu 24.04 apt; install the latest release binary to ~/.local/bin.
if have lazygit; then
  info "lazygit already installed: $(command -v lazygit) (skip)"
elif ! have curl; then
  info "curl not found, skipping lazygit"
else
  info "installing lazygit..."
  case "$(uname -m)" in
    x86_64) lg_arch=x86_64 ;;
    aarch64|arm64) lg_arch=arm64 ;;
    *) info "unsupported arch $(uname -m) for lazygit, skipping"; lg_arch="" ;;
  esac
  if [ -n "$lg_arch" ]; then
    lg_ver=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
      | grep -Po '"tag_name": *"v\K[^"]*')
    tmp=$(mktemp -d)
    curl -fsSL -o "$tmp/lazygit.tar.gz" \
      "https://github.com/jesseduffield/lazygit/releases/download/v${lg_ver}/lazygit_${lg_ver}_Linux_${lg_arch}.tar.gz"
    tar -xf "$tmp/lazygit.tar.gz" -C "$tmp" lazygit
    mkdir -p "$HOME/.local/bin"
    install "$tmp/lazygit" "$HOME/.local/bin/lazygit"
    rm -rf "$tmp"
    info "lazygit ${lg_ver} installed to ~/.local/bin"
  fi
fi

info "done."
