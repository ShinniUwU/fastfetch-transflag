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

It lets you preview both looks live in your terminal and installs whichever one you pick into `~/.config/fastfetch/`.

The script auto-detects the best way to render the logo in *your* terminal (Kitty, Konsole, WezTerm, iTerm2, etc.), asks you to confirm the image actually showed up, and remembers that choice (in `~/.cache/transarch-fastfetch-logo-type`) so you never have to fiddle with flags again. If your terminal doesn't support inline images at all, it falls back to a plain-text logo automatically — everything else (OS, CPU, GPU, etc.) still displays correctly either way. No network access, no telemetry, nothing installed without asking first.

### The Two Looks

#### 1. Default look

![Default Preview](/assets/fastfetch_preview.png)

- Config: `config.jsonc`
- Logo: `logos/trans_default.png`

Manual setup:

1. Create a folder named `fastfetch` in `~/.config/`.
2. Inside it, place `config.jsonc` and the `logos` folder.

#### 2. Customized look

![Customized Preview](/assets/customized_preview.png)

- Config: `config-customized.jsonc`
- Logo: `logos/trans_customized.png`

Manual setup:

1. Create a folder named `fastfetch` in `~/.config/`.
2. Copy `config-customized.jsonc` to `~/.config/fastfetch/config.jsonc` and place the `logos` folder alongside it.

### Usage

Once the configuration is set up, just type `fastfetch` in the terminal to enjoy the personalized system information display.

### Known Bugs

- If you set up a look manually (not via `choose-look.sh`) and see raw text like `PNG` or garbled characters where the logo should be, your terminal doesn't support inline image rendering. This isn't a broken config — fastfetch still shows all your system info correctly, just with a plain-text logo instead of the flag image. Using `choose-look.sh` avoids this by testing render modes for you before installing anything.
