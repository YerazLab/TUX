# TUX
Awesome MOTD for Ubuntu with system information and more.

> **Note:** Successfully tested on **Ubuntu 18** to **25+**.

<img src="https://raw.githubusercontent.com/YerazLab/TUX/refs/heads/main/ressources/screenshot.png" width="400">


# Prerequisites

TUX uses glyphs (icons) to display some informations. To view these elements properly in your SSH terminal, you need to install a Nerd Font (such as Fira Code, DejaVuSans, etc.) on your local machine. Nerd Fonts are standard fonts that have been patched to include over 10,000 icons from Font Awesome, Material Design, and more.

# Installation

## Automatic
All features will be installed (like the silent flag).

    curl https://raw.githubusercontent.com/YerazLab/TUX/refs/heads/main/install.sh | sudo bash -s -


## Manual
You will be prompted to select the features to install.

    curl -O https://raw.githubusercontent.com/YerazLab/TUX/refs/heads/main/install.sh
    chmod +x ./install.sh
    sudo bash -i ./install.sh

> **Warning:** You need to start the installer as an interactive user (**bash -I**). If you don't, no dialogs will be shown.

## Parameters

| Option | Description |
|-|-|
| `--silent` | Disable all questions and enable all features |
| `--help` | Show the helper and exit |

  
# Update

    cd /opt/TUX/repo
    git pull


# Extra

## Custom services detection

Edit **/etc/TUX/motd.services.txt** and add one service per line, with the format: **name;service**. For example:

    Nginx Web Server;nginx
    My firewall;ufw

> **Note:** Do not add **.service** in the service name.

## Activate VENV

For testing or debugging:

    cd /opt/TUX/repo/scripts
    source venv-activate.sh

## MOTD debug

If the MOTD is not showing at login, edit **/etc/update-motd.d/99-tux-motd** and modify the relevant line as follows. Then logout and login again. Double-check the log at **/tmp/tuxmotd.log**

    tux_motd 2> /tmp/tuxmotd.log