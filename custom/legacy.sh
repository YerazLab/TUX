#!/bin/bash

source "scripts/functions.sh"

# Le script est sourcé
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