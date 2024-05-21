## TransArch - A Simplified Fastfetch Configuration for Trans Users

This repository aims to streamline the process of configuring and utilizing Fastfetch for new Arch Linux users, specifically those within the transgender community.

### Preview

![Fastfetch Preview](/assets/fastfetch_preview.png)

### Why Fastfetch?

Fastfetch is preferred over Hyfetch for its immediate display of system information upon launching the terminal. While Hyfetch is functional, its execution speed is comparatively slower due to being written in Python. In contrast, Fastfetch, coded in C, provides almost instant access to system details.

### How to Use

#### Installation

If Fastfetch is not yet installed, execute the following command:

```bash
sudo pacman -S fastfetch
```

#### Configuration

1. Upon installing Fastfetch, no additional setup is needed.

2. Simply create a folder named `fastfetch` in `~/.config/`.

3. Inside the `fastfetch` folder, place `config.jsonc` and the `Logo` folder.

4. Open the `config.jsonc` file and edit the logo path to point to the location of the downloaded image:

```json
"logo": "/home/[name_of_your_pc]/.config/fastfetch/Logo/trans_arch.png"
```

5. Save and exit the `config.jsonc` file.

### Usage

Once the configuration is set up, just type `fastfetch` in the terminal to enjoy the personalized system information display.

### Check out Customized Versions

- **Customized Branch:** Explore my [customized](https://github.com/ShinniUwU/fastfetch-transflag/tree/customized) branch for an enhanced visual experience.

### Known Bugs

- Some terminals may not render the PNG logo correctly. Compatibility has been confirmed with Kitty and Konsole; other terminals may exhibit issues.
