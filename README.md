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

### The Two Looks

#### 1. Default look

![Default Preview](/assets/fastfetch_preview.png)

- Config: `config.jsonc`
- Logo: `Logo/trans_arch.png`

Manual setup:

1. Create a folder named `fastfetch` in `~/.config/`.
2. Inside it, place `config.jsonc` and the `Logo` folder.

#### 2. Customized look

![Customized Preview](/assets/customized_preview.png)

- Config: `config-customized.jsonc`
- Logo(s): `pngs/` (a random PNG from this folder is picked on every launch)

Manual setup:

1. Create a folder named `fastfetch` in `~/.config/`.
2. Copy `config-customized.jsonc` to `~/.config/fastfetch/config.jsonc` and place the `pngs` folder alongside it.

### Usage

Once the configuration is set up, just type `fastfetch` in the terminal to enjoy the personalized system information display.

### Known Bugs

- Some terminals may not render the PNG logo correctly. Compatibility has been confirmed with Kitty and Konsole; other terminals may exhibit issues.
