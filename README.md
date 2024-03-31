## TransArch - A Simplified Fastfetch Configuration for Trans Users

This repository exists as a means to simplify the process of configuring and using Fastfetch for newer Arch Linux users, particularly those in the transgender community. 

### Why Fastfetch?

Fastfetch is chosen over Hyfetch for its instantaneous display of system information upon opening the terminal. While Hyfetch is functional, it is comparatively slower due to being coded in Python, whereas Fastfetch is coded in C, offering near-instant access to system information.

### How to Use

#### Installation

If you haven't already installed Fastfetch, you can do so using the following command:

```bash
sudo pacman -S fastfetch
```

#### Configuration

1. After installing Fastfetch, generate a configuration file by running:

```bash
fastfetch --gen-config
```

2. Customize your configuration file (`config.jsonc`) according to your preferences. You can find a list of available commands [here](https://github.com/fastfetch-cli/fastfetch/blob/dev/presets/all.jsonc).

3. Download the `config.jsonc` file provided in this repository.

4. Place the downloaded `config.jsonc` file into the following directory:

```bash
/home/[name_of_your_pc]/.config/fastfetch/
```

5. Create a folder named `Logo` in the same directory.

6. Download the image provided in this repository and place it into the `Logo` folder.

7. Open the `config.jsonc` file and edit the logo path to point to the location of the downloaded image:

```json
"logo": "/home/[name_of_your_pc]/.config/fastfetch/Logo/trans_arch.png"
```

8. Save the `config.jsonc` file.

### Usage

Once the configuration is set up, simply type `fastfetch` in the terminal, and enjoy the personalized system information display.
