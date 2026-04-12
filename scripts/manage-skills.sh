#!/usr/bin/env bash
set -euo pipefail

mode="${1:-install}"
if [ "$mode" != "install" ] && [ "$mode" != "uninstall" ]; then
  echo "Usage: $0 [install|uninstall]" >&2
  echo "  Default: install" >&2
  exit 1
fi

SKILL_PREFIX="neat-sdd-"
root="$(cd "$(dirname "$0")/.." && pwd)"
dst="$HOME/.claude/skills"

if [ "$mode" = "install" ]; then
  mkdir -p "$dst"
fi

for src in "$root"/${SKILL_PREFIX}*; do
  [ -d "$src" ] || continue
  [ -f "$src/SKILL.md" ] || continue

  name=$(sed -n '/^name:/s/^name: *//p' "$src/SKILL.md" | head -1)
  if [ -z "$name" ]; then
    echo "ERROR: no name in $src/SKILL.md frontmatter" >&2
    continue
  fi

  src_real="$(realpath "$src")"

  if [ "$mode" = "install" ]; then
    # Skip if already correctly installed
    if [ -L "$dst/$name" ]; then
      dst_real="$(realpath "$dst/$name")"
      if [ "$dst_real" = "$src_real" ]; then
        echo "INFO: $name already installed — skipping"
        continue
      fi
    fi
    if [ -e "$dst/$name" ]; then
      echo "WARN: $dst/$name already exists — skipping"
      continue
    fi

    ln -s "$src" "$dst/$name" && echo "INFO: $name installed"

  else  # uninstall
    # Only remove if installed by this project
    if [ -L "$dst/$name" ]; then
      dst_real="$(realpath "$dst/$name")"
      if [ "$dst_real" = "$src_real" ]; then
        rm "$dst/$name" && echo "INFO: $name uninstalled"
      else
        echo "WARN: $name exists but was not installed by this project — skipping"
      fi
    elif [ -e "$dst/$name" ]; then
      echo "WARN: $name exists but was not installed by this project — skipping"
    else
      echo "INFO: $name not installed — skipping"
    fi
  fi
done
