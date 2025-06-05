#!/bin/bash

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change le prompt PS1
change_ps1() {
    LINE='if [ -n "$BASH_VERSION" ] && [[ $- == *i* ]]; then
        PS1="\[\e[48;5;22m\e[38;5;255m\] [\u]\[\e[0m\] \w > "
    fi'

    files=()
    files+=("/etc/bash.bashrc")
    files+=("/etc/skel/.bashrc")
    files+=("/root/.bashrc")

    for dir in /home/*; do
        if [ -f "$dir/.bashrc" ]; then
            files+=("$dir/.bashrc")
        fi
    done

    for file in "${files[@]}"; do
        print_msg "OK" "PS1" "Modification of the PS1 prompt on $file"
        echo -e "\n$LINE" >> "$file"
    done
}

# Configure le PS1
init_ps1() {
    if print_dialog $SILENT "Modify the PS1 prompt?"; then

        if [ "$SILENT" = "yes" ]; then printf "\n"; fi

        print_msg "OK" "PS1" "Modifying the PS1 prompt"
        change_ps1
    else
        print_msg "INFO" "PS1" "Skipping the PS1 prompt modification"
    fi
}

main() {
    cd "$MODULE_DIR"

    print_header "Module PS1 installation"

    init_ps1

    cd ..
}

main "$@"