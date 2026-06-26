#!/usr/bin/env bash
# Idempotent installer for CLI tools used by this dotfiles setup.
# Keeps tool provisioning separate from config (.bashrc) — re-running is safe.
set -ue

info() { command echo -e "\e[1;34m[install_tools]\e[m $*"; }

# --- Claude Code -----------------------------------------------------------
if command -v claude >/dev/null 2>&1; then
  info "claude already installed: $(command -v claude) (skip)"
else
  info "installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
fi

# --- fzf -------------------------------------------------------------------
# apt's fzf (0.44) lacks `--bash`; use git for the latest + ~/.fzf.bash.
if [ -d "$HOME/.fzf" ]; then
  info "fzf already cloned, updating..."
  git -C "$HOME/.fzf" pull --ff-only || true
else
  info "installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
fi
"$HOME/.fzf/install" --key-bindings --completion --no-update-rc

# --- apt tools: fd / bat / zoxide / eza / ripgrep --------------------------
# Ubuntu binary names: fd-find -> fdfind, bat -> batcat (aliased in .bashrc).
apt_pkgs=(fd-find bat zoxide eza ripgrep)
missing=()
for cmd in fdfind batcat zoxide eza rg; do
  command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done
if [ ${#missing[@]} -eq 0 ]; then
  info "apt tools already installed (skip apt)"
else
  info "installing via apt: ${apt_pkgs[*]} (missing: ${missing[*]})"
  sudo apt-get update -qq
  sudo apt-get install -y "${apt_pkgs[@]}"
fi

# --- lazygit ---------------------------------------------------------------
# Not in Ubuntu 24.04 apt; install the latest release binary to ~/.local/bin.
if command -v lazygit >/dev/null 2>&1; then
  info "lazygit already installed: $(command -v lazygit) (skip)"
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
