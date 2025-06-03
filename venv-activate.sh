#!/bin/bash

#= SETTINGS ========================================================================================================

VENV_DIR="/opt/TUX/venv"

COLOR_OK_FG="\e[32m"
COLOR_OK_BG="\e[42m\e[30m"
COLOR_CRITICAL_FG="\e[31m"
COLOR_CRITICAL_BG="\e[41m\e[30m"
COLOR_HIGHLIGHT_FG="\e[1m\e[93m"
COLOR_HIGHLIGHT_FG_REGULAR="\e[93m"
COLOR_HIGHLIGHT_BG="\e[43m\e[30m"
COLOR_INFO_FG="\e[35m"
COLOR_INFO_BG="\e[45m\e[30m"
COLOR_RESET="\e[0m"

LABEL_WIDTH="10"

#= COMMON FEATURES =================================================================================================

# Affiche un messsage
print_msg() {
    case "$1" in
        "OK")
            local color1="$COLOR_OK_FG"
            local color2="$COLOR_OK_BG"
            ;;
        "ERROR")
            local color1="$COLOR_CRITICAL_FG"
            local color2="$COLOR_CRITICAL_BG"
            ;;
        "INFO")
            local color1="$COLOR_INFO_FG"
            local color2="$COLOR_INFO_BG"
            ;;
    esac 

    local label="$2"
    local label_len=${#label}+2
    local pad=$(($LABEL_WIDTH - label_len))
    (( pad < 1 )) && pad=1

    printf "${color2} ${label} ${COLOR_RESET}%*s${color1}${3}${COLOR_RESET}\n" "$pad"
}

# Affiche un message avec une boîte
print_box() {
    local padding=1
    local args=("$@")
    local last_index=$((${#args[@]} - 1))
    local box_width="${args[$last_index]}"
    local lines=("${args[@]:0:$last_index}")

    printf '┌'
    printf '─%.0s' $(seq 1 "$box_width")
    printf '┐\n'

    for line in "${lines[@]}"; do
        clean_line=$(echo -e "$line" | sed -r 's/\x1B\[[0-9;]*[mK]//g')
        space_count=$((box_width - ${#clean_line} - padding))
        printf '│'
        printf ' %.0s' $(seq 1 $padding)
        printf "%b" "$line"
        printf ' %.0s' $(seq 1 $space_count)
        printf '│\n'
    done

    printf '└'
    printf '─%.0s' $(seq 1 "$box_width")
    printf '┘\n'
}

# l'utilisateur est chroot
check_isroot() {
    if [ "$(id -u)" != "0" ]; then
        print_msg "ERROR" "SCRIPT" "This script must be run as root"
        printf "\n\n"
        print_box "${COLOR_OK_FG}In order to run in as root use :${COLOR_RESET}" \
                  "" \
                  "${COLOR_OK_FG}sudo bash -i ./venv-activate.sh${COLOR_RESET}" \
                  80
        
        return 1
    else
        print_msg "OK" "SCRIPT" "Script run with root privileges"
        return 0
    fi
}

#= MAIN FEATURES ===================================================================================================

main() {

    check_isroot    || { quit_installation; return; }
    print_msg "OK" "VENV" "Activating virtual environment"
    source $VENV_DIR/bin/activate
    printf "\n\n"
}

main "$@"