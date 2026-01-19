# Dotfiles for Agent Configs

This repo centralizes global agent configs (AGENTS.md, Codex configs, skills) and links them into tool-specific locations via scripts.

## Layout

- AGENTS.md
- mappings.txt
- codex/
  - config.toml
  - rules/
  - skills/

## Quick start

1) Update mappings:
- Edit `mappings.txt` in the repo root.
- Format: `source:destination` per line.
- Use `mappings.example.txt` from the `agent-dotfiles` skill if needed.

2) Link files (Windows):
```powershell
powershell -ExecutionPolicy Bypass -File scripts\link_dotfiles.ps1 `
  -DotfilesRoot "$env:USERPROFILE\dotfiles" `
  -MappingFile "$env:USERPROFILE\dotfiles\mappings.txt"
```

3) Link files (macOS/Linux):
```bash
chmod +x scripts/link_dotfiles.sh
./scripts/link_dotfiles.sh --root "$HOME/dotfiles" --map "$HOME/dotfiles/mappings.txt"
```

## Notes

- Avoid linking secrets (auth.json, tokens, history, cache).
- Windows symlinks may require Administrator privileges; scripts fall back to hardlinks or junctions.
- The scripts skip existing targets unless `-Force` / `--force` is used.
- Backups are created with `.bak.<timestamp>` when force is enabled.

## Updating

- Edit files under this repo and re-run the link script if needed.
- If you change `mappings.txt`, re-run the link script to apply new links.
