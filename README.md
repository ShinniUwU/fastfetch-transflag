## TransArch - A Simplified Fastfetch Configuration for Trans Users

This repository aims to streamline the process of configuring and utilizing Fastfetch for new Arch Linux users, specifically those within the transgender community.

This repo now ships **two looks** side by side, plus a script to preview and pick one interactively.

### Why Fastfetch?

Fastfetch is preferred over Hyfetch for its immediate display of system information upon launching the terminal. While Hyfetch is functional, its execution speed is comparatively slower due to being written in Python. In contrast, Fastfetch, coded in C, provides almost instant access to system details.

### Quick Start (recommended)

If Fastfetch is not yet installed, execute the following command:

```bash
sudo pacman -S fastfetch
```

Then run the picker script from the repo root:

```bash
./choose-look.sh
```

It lets you preview the looks live in your terminal and installs whichever one you pick into `~/.config/fastfetch/`. Your existing `config.jsonc` is backed up first as `config.jsonc.bak-<timestamp>`.

Skip the menu with flags:

```bash
./choose-look.sh --list            # show available looks
./choose-look.sh --look customized # install one, no prompts
./choose-look.sh --uninstall       # remove the installed config and logos
```

The script auto-detects the best way to render the logo in *your* terminal (Kitty, Konsole, WezTerm, iTerm2, etc.), asks you to confirm the image actually showed up, and remembers that choice (in `~/.cache/transarch-fastfetch-logo-type`) so you never have to fiddle with flags again. If your terminal doesn't support inline images at all, it falls back to a plain-text logo automatically, and everything else (OS, CPU, GPU, etc.) still displays correctly either way. No network access, no telemetry, nothing installed without asking first.

### The Looks

Each look lives in `looks/<name>/` as a `config.jsonc` and a `logo.png`.

#### default

![Default Preview](/assets/default.png)

#### customized

![Customized Preview](/assets/customized.png)

### Manual setup

Prefer not to run the script? Copy a look by hand:

1. `mkdir -p ~/.config/fastfetch/logos`
2. `cp looks/<name>/config.jsonc ~/.config/fastfetch/config.jsonc`
3. `cp looks/<name>/logo.png ~/.config/fastfetch/logos/<name>.png`

### Usage

Once the configuration is set up, just type `fastfetch` in the terminal to enjoy the personalized system information display.

### Contributing

Want to add a look? See [CONTRIBUTING.md](CONTRIBUTING.md). It takes one folder.

### Troubleshooting

- If you set up a look manually (not via `choose-look.sh`) and see raw text like `PNG` or garbled characters where the logo should be, your terminal doesn't support inline image rendering. This isn't a broken config, fastfetch still shows all your system info correctly, just with a plain-text logo instead of the flag image. Using `choose-look.sh` avoids this by testing render modes for you before installing anything.
