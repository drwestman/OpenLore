#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

bun install --no-save
bun run build

expected_version="$(node -p "require('./package.json').version")"
bun_install_dir="${BUN_INSTALL:-${HOME}/.bun}"
global_bin="${bun_install_dir%/}/bin"
global_command="$global_bin/openlore"

mkdir -p "$global_bin"
chmod +x "$script_dir/dist/cli/index.js"
ln -sfn "$script_dir/dist/cli/index.js" "$global_command"

installed_version="$("$global_command" --version)"

if [[ "$installed_version" != "$expected_version" ]]; then
  printf 'Expected OpenLore %s, but the global command reports %s.\n' \
    "$expected_version" "$installed_version" >&2
  exit 1
fi

printf 'Installed OpenLore %s globally at %s/openlore.\n' \
  "$installed_version" "$global_bin"
