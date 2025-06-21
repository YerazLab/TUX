# TUX.motd
Awesome MOTD for Ubuntu with system information and more.

> **Note:** Successfully tested on **Ubuntu 20** to **25+**.

<img src="https://raw.githubusercontent.com/YerazLab/TUX/refs/heads/main/ressources/screenshot.png" width="400">

# Prerequisites

TUX.motd uses optional glyphs (icons) to display some informations. To view these elements properly in your SSH terminal, you need to install a Nerd Font (such as Fira Code, DejaVuSans, etc.) on your local machine. Nerd Fonts are standard fonts that have been patched to include over 10,000 icons from Font Awesome, Material Design, and more.

# Installation

Use the [TUX installation](../../README.md) to install TUX.motd.

# Debug

If the TUX.motd is not showing at login, edit **/etc/update-motd.d/99-tux-motd** and modify the relevant line as follows. Then logout and login again. Double-check the log at **/tmp/tuxmotd.log**

    tux_motd 2> /tmp/tuxmotd.log

# Developpment

In this example, we activate the virtual environment (VENV) and use nano to edit the tux_motd.py file.

    sudo -i
    cd /opt/TUX/repo/
    source ./scripts/venv-activate.sh
    cd src/tux_motd/src
    nano tux_motd.py
    ./tux_motd.py

> **Note:** An interactive root session is required to access certain internal features.

# Settings

The TUX.motd configuration can be found in the following file. All parameters are optional. The values provided below represent the default configuration.

    /etc/TUX/text.motd.yaml

## Language

    language: "fr"

> **Note:** Two languages are currently available: English (**en**) by default, and French (**fr**).
To add new languages, duplicate one of the existing language folders in the **i18n** directory and modify the **messages.po** file accordingly. Once your changes are complete, compile the file using the following command: **msgfmt -o messages.mo messages.po**

## Theme

    theme:
        hostname: "green"
        title: "white"
        ok: "green"
        warning: "magenta"
        critical: "red"
        highlight: "yellow"

> **Note:** The colors correspond to the colorama foreground values.

## Bargraph

    graph:
        width: 50
        symbol: "─"
        track_color: "black"

## Box

    box:
        width: 50
        color: "yellow"

## Modules

For each TUX.motb module, you can set the position and the display.

    modules: 
        - {module}
            position: 1
            show: true

> **Note :** See the default configuration on **/etc/TUX/text.motd.yaml** for usage of the different modules.

### Module Host

You can display all the content (hostname, distro, uptime, update) in one place with:

    - host:

Or, alternatively, content by content with:

    - host:
        content:
            - hostname:
                font: "termius"
            - distro:
                icon: ""
            - uptime:
                icon: ""
            - update:
                icon: "󰏓"
            - banner:
                message:
                    all: "Authorized personnel only. Or very sneaky cats."
                    ...
                    your_username: "Hi!"

> **Note 1 :** You can use any default Fyglet font name.
> **Note 2 :** Each **content** support **show** parameter.

### Module Processor

    - processor:
        icon:
            info : ""
            graph : ""

### Module Memory

    - memory:
        icon:
            info : ""
            graph: ""
        treshold:
            warn: 70
            critical: 90

### Module Disk

    - disk:
        exclude:
            - "/snap"
            - "/var/lib/snapd"
            - "/run/snapd"
            - "/System"
            - "/boot"
            ...
            - "/your_mount_point"
        icon:
            info : ""
            graph: ""
        treshold: 
            warn: 5
            critical: 10

### Module Service

    - service:
        icon: "󰒔"
        check:
            PHP FPM: php8.1-fpm
            Nginx: nginx
            MariaDB: mariadb
            UFW: ufw
            PostgreSQL: postgresql
            ...
            Your_Service_Name: your_service

### Module Network

You can display all the content (interface, route, resolver, firewall) in one place with:

    - network:
        ipv4: true
        ipv6: false
        exclude:
            - "lo"
            ...
            - "your_interface"

Or, alternatively, content by content with:

    - network:
        content:
            - interface:
                icon: "󱦂"    
            - route:
                icon: "󱇢"
            - resolver:
                icon: "󰖟"
            - firewall:
                icon: "󰕥"

> **Note :** Each **content** support **show** parameter.

### Module User
  
    - user:
        icon: ""