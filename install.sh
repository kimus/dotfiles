#!/bin/sh

set -e # -e: exit on error

# install chezmoi
if [ ! "$(command -v chezmoi)" ]; then
  bin_dir="$HOME/.local/bin"
  chezmoi="$bin_dir/chezmoi"
  if [ "$(command -v curl)" ]; then
    sh -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "$bin_dir"
  elif [ "$(command -v wget)" ]; then
    sh -c "$(wget -qO- https://git.io/chezmoi)" -- -b "$bin_dir"
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    exit 1
  fi
else
  chezmoi=chezmoi
fi

# install Bitwarden CLI
BW_URL="https://vault.bitwarden.com/download/?app=cli&platform=linux"
BW_FILE=$(mktemp)
if [ "$(command -v curl)" ]; then
    curl -fsL $BW_URL -o $BW_FILE
elif [ "$(command -v wget)" ]; then
    wget -q $BW_URL -O $BW_FILE
fi
unzip -o $BW_FILE -d "$HOME/.local/bin"
rm $BW_FILE
echo "Bitwarden CLI installed"
export BW_SESSION=$(bw login $BW_EMAIL $BW_PASSWORD --raw)

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

# exec: replace current process with chezmoi init
exec "$chezmoi" init --apply "--source=$script_dir"
