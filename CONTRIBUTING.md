# Contributing

Thanks for helping out. This repo is trans-flag only: new looks are welcome, other flags are out of scope.

## Add a look

1. Create `looks/<name>/` (lowercase, no spaces).
2. Add `config.jsonc` and `logo.png` to it.
3. In `config.jsonc`, set the logo line to exactly:
   `"logo": "~/.config/fastfetch/logos/<name>.png"`
   The installer swaps this line for the right render mode for the user's terminal.
4. Run `./choose-look.sh --list` and check your look shows up.
5. Add a screenshot at `assets/<name>.png` and a section for it in the README.

## Test your change

```bash
bash -n choose-look.sh
shellcheck choose-look.sh
XDG_CONFIG_HOME=$(mktemp -d) ./choose-look.sh --look <name>
```

The last line installs into a temp dir, so your real config is untouched.

## Style

- Bash, `set -euo pipefail`, no new dependencies.
- No network calls, no telemetry.
- Commit messages follow Conventional Commits (`feat:`, `fix:`, `docs:`).
