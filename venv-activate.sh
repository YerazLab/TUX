#!/bin/bash

source scripts/functions.sh

venv_dir="/opt/TUX/venv"

bash_installation() {
    clear_screen
    start_tux

    check_isroot    || { quit_installation; return; }
    print_msg "OK" "VENV" "Activating virtual environment"
    source $venv_dir/bin/activate
    printf "\n\n"
}

bash_installation