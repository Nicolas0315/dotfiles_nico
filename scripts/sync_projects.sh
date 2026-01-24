#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT=""
PROJECTS_FILE=""
FORCE=0

usage() {
  echo "Usage: sync_projects.sh --root <dotfiles_root> --projects <projects_file> [--force]"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --root)
      DOTFILES_ROOT="$2"
      shift 2
      ;;
    --projects)
      PROJECTS_FILE="$2"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [ -z "$DOTFILES_ROOT" ]; then
  DOTFILES_ROOT="$HOME/dotfiles"
fi
if [ -z "$PROJECTS_FILE" ]; then
  PROJECTS_FILE="$DOTFILES_ROOT/projects.txt"
fi

SOURCE="$DOTFILES_ROOT/AGENTS.md"
if [ ! -f "$SOURCE" ]; then
  echo "Source AGENTS.md not found: $SOURCE" >&2
  exit 1
fi
if [ ! -f "$PROJECTS_FILE" ]; then
  echo "Projects file not found: $PROJECTS_FILE" >&2
  exit 1
fi

while IFS= read -r line || [ -n "$line" ]; do
  line="${line%%#*}"
  line="$(printf "%s" "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  if [ -z "$line" ]; then
    continue
  fi

  project="$line"
  if [[ "$project" == "~/"* ]]; then
    project="$HOME/${project:2}"
  fi

  if [ ! -d "$project" ]; then
    echo "Missing project: $project" >&2
    continue
  fi

  target="$project/AGENTS.md"
  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ "$FORCE" -eq 1 ]; then
      ts="$(date +%Y%m%d%H%M%S)"
      mv "$target" "${target}.bak.${ts}"
    else
      echo "Skip existing: $target" >&2
      continue
    fi
  fi

  ln -s "$SOURCE" "$target"
  echo "Linked: $target -> $SOURCE"
done < "$PROJECTS_FILE"
