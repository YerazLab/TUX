#!/bin/bash

set -e

source scripts/functions.sh

PYTHON3=$(which python3)

repository="https://yeraz-repos@dev.azure.com/yeraz-repos/Tux/_git/Tux"

packages_dir="/opt/TUX/packages"
venv_dir="/opt/TUX/venv"

git_clone_or_update() {
    if has_command git; then
        if [ -d "$packages_dir" ] && [ -d "$packages_dir/.git" ]; then
            git_update
        else
            git_clone
        fi
    else
        set_error "GIT" "Git is not installed, please install git to continue"
    fi
}

git_update() {
    print_msg "OK" "GIT" "Updating TUX repository"
    cd $packages_dir
    if git pull > /dev/null 2>tux_error.log; then
        set_success "GIT" "TUX repository updated successfully"
    else
        set_error "GIT" "TUX repository update error"
        return 1
    fi

    return 0
}

git_clone() {
    print_msg "OK" "GIT" "Cloning TUX repository"
    if git clone $repository $packages_dir > /dev/null 2>tux_error.log; then
        set_success "GIT" "TUX repository updated successfully"
        cd $packages_dir
    else
        set_error "GIT" "TUX repository update error"
        return 1
    fi

    return 0
}

# Installation des packages de VENV
install_venv() {
    if grep -qi ubuntu /etc/os-release 2>/dev/null; then
        if apt install python3-venv -y > /dev/null 2>tux_error.log; then
            set_success "VENV" "VENV package installed successfully"
        else
            set_error "VENV" "VENV package installation error"
        fi
    fi      

    return
}

# Création et activation d'un environnement virtuel
create_venv() {
    print_msg "OK" "VENV" "Python in use : $PYTHON3"
    if $PYTHON3 -m venv $venv_dir --system-site-packages > /dev/null 2>tux_error.log; then
        set_success "VENV" "Creating virtual environment in $venv_dir"
    else
        set_error "VENV" "Virtual environment creation error"
    fi

    return
}

# Active le VENV
activate_venv() {
    if source $venv_dir/bin/activate > /dev/null 2>tux_error.log; then
        set_success "VENV" "Virtual environment activated successfully"

        print_msg "OK" "VENV" "Redirect python binary to virtual environment"
        PYTHON3="$venv_dir/bin/python3"
    else
        set_error "VENV" "Virtual environment activation error"
    fi

    return
}

# Met à jour PIP
upgrading_pip() {
    if $PYTHON3 -m pip install --upgrade pip > /dev/null 2>tux_error.log; then
        set_success "PIP" "PIP upgraded successfully"
    else
        set_error "PIP" "PIP upgraded error"
    fi

    return
}

# Installation des modules
install_modules() {
    print_msg "OK" "MODULE" "Start to installing modules"
    cd src

    for PLUGIN in */ ; do
        if [ -f "$PLUGIN/install.sh" ]; then
            source "$PLUGIN/install.sh"
        fi
    done
}

# Message de fin
end_message() {
    printf "\n\n${highlight_color_bg}"
    printf " Install completed sucessfully ${reset}\n"
    #printf " Activate the virtual environment? \n"

    cd ../
}

main() {
    clear_screen
    start_message

    check_isroot        || { quit_installation; return; }
    check_issourced     || { quit_installation; return; }

    #git_clone_or_update || { quit_installation; return; }

    print_header "Environnement installation"
    install_venv        || { quit_installation; return; }
    create_venv         || { quit_installation; return; }
    activate_venv       || { quit_installation; return; }
    upgrading_pip       || { quit_installation; return; }
    install_modules

    end_message

#    dialog "Yes" "No"
#    if [ $REPLY -eq "0" ]; then
#        deactivate
#    else
#        cd src
#    fi
    printf "\n\n"

}

main