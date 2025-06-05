#!/bin/bash

#= SETTINGS ========================================================================================================

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

# Affiche un en-tête
print_header() {
    printf "\n${COLOR_HIGHLIGHT_FG}${1}${COLOR_RESET}\n"
}

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

# Verifie si un script est exécuté ou sourcé
is_sourced() {
   if [ -n "$ZSH_VERSION" ]; then 
       case $ZSH_EVAL_CONTEXT in *:file:*) return 1;; esac
   else
       case ${0##*/} in dash|-dash|bash|-bash|ksh|-ksh|sh|-sh) return 1;; esac
   fi
   return 0
}

# Efface l'écran
clear_screen() {
    printf '%b\n' '\033[2J\033[:H'
}

# l'utilisateur est chroot
check_isroot() {
    if [ "$(id -u)" != "0" ]; then
        print_msg "ERROR" "SCRIPT" "This script must be run as root"
        printf "\n\n"
        print_box "${COLOR_OK_FG}In order to run in as root use :${COLOR_RESET}" \
                  "" \
                  "${COLOR_OK_FG}$ sudo bash -i ./custom/legacy.sh${COLOR_RESET}" \
                  80
        
        return 1
    else
        print_msg "OK" "SCRIPT" "Script run with root privileges"
        return 0
    fi
}

profile_modification() {
    PROFILE="/etc/profile"
    BACKUP="/etc/profile.bak.$(date +%Y%m%d)"

    print_header "Profile modification\n"

    cp "$PROFILE" "$BACKUP"
    print_msg "OK" "LEG" "Backup of $PROFILE on $BACKUP"

    sed -i '/^# Lancer le script$/,/^fi$/d' "$PROFILE"
    print_msg "OK" "LEG" "Remove previous script calling"
}

remove_script() {

    print_header "Remove legacy script\n"

    files=()

    while IFS= read -r -d '' file; do
        files+=("$file")
    done < <(find /home -type f -name 'bp-test*' -print0)

    if [ ${#files[@]} -eq 0 ]; then
        print_msg "INFO" "LEGACY" "No files found"
    else
        for file in "${files[@]}"; do
            print_msg "OK" "LEGACY" "Delete $file"
            rm -Rf "$file"
        done
    fi
}

main() {
    clear_screen
    check_isroot || { quit_installation; return; }

    profile_modification
    remove_script

    printf "\n\n"
}

main "$@"