#!/bin/bash

set -e

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Installation des packages python
install_requirements() {
    if $PYTHON3 -m pip install -r "$MODULE_DIR/requirements.txt" > /dev/null 2>tux_error.log; then
        set_success "MOTD" "Requirements installed successfully"
    else
        set_error "MOTD" "Failed to install requirements"
    fi
}

# Installation de la police figlet
install_font() {
    if pyfiglet -L "$MODULE_DIR/ressources/termius.flf" > /dev/null 2>tux_error.log; then
        set_success "MOTD" "Figlet font installed successfully"
    else
        set_error "MOTD" "Failed to install font"
    fi
}

# Créé la configuration de base
init_configuration() {
    if has_command systemctl; then
        print_msg "OK" "MOTD" "Configuration initialized"
        mkdir -p "/etc/TUX/"

        local input_file="$MODULE_DIR/ressources/services.txt"
        local output_file="/etc/TUX/motd.services.txt"

        > "$output_file"

        while IFS=";" read -r name svc; do
            [ -z "$svc" ] && continue

            if systemctl list-unit-files --type=service | grep -q "^${svc}\.service"; then
                echo "${name};${svc}" >> "$output_file"
            fi
        done < "$input_file"
    else 
        print_msg "OK" "MOTD" "No systemctl command"
    fi
}

# Compilation des packages python
build_module() {
    if $PYTHON3 -m pip install "$MODULE_DIR" > /dev/null 2>tux_error.log; then
        set_success "MOTD" "Module built successfully"
    else
        set_error "MOTD" "Failed to build module"
    fi
}

# Nettoyage des fichiers
clean_module() {
    if {
        $PYTHON3 setup.py clean --all &&
        rm -rf *.egg-info
        rm -rf __pycache__
    } > /dev/null 2>tux_error.log; then
        set_success "MOTD" "Module cleaned successfully"
    else
        set_error "MOTD" "Failed to cleaning module"
    fi
}

link_module() {
    print_msg "OK" "MOTD" "Linking module to /usr/local/bin"
    ln -sf $venv_dir/bin/tux_motd /usr/local/bin/tux_motd
}

init_motd() {
    local motd_dir="/etc/update-motd.d"

    if [ ! -d "$motd_dir" ]; then
        mkdir -p "$motd_dir"
    else 
        print_msg "OK" "MOTD" "Disabled all MOTD dynamic configuration"
        chmod -x $motd_dir/*
    fi

    print_msg "OK" "MOTD" "Initializing tux_motd configuration"
    tee $motd_dir/99-tux-motd > /dev/null <<EOF
#!/bin/bash
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
tux_motd
EOF

    print_msg "OK" "MOTD" "Set execute permission to tux_motd"
    sudo chmod +x $motd_dir/99-tux-motd
}

clean_legacy() {
    print_msg "OK" "MOTD" "Cleaning legacy motd"
}

disabled_printlastlog() {
    print_msg "OK" "MOTD" "Disabled SSHD print last log"
}

main() {
    cd "$MODULE_DIR"

    print_header "Module Motd installation"

    install_requirements || { quit_installation; return; }
    install_font || { quit_installation; return; }
    build_module || { quit_installation; return; }
    clean_module || { quit_installation; return; }
    link_module
    init_motd
    clean_legacy

    init_configuration

    cd ..
}

main