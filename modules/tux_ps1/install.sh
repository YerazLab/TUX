#!/bin/bash

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly BACK_COLOR1="\[\e[48;5;22m\]"
readonly BACK_COLOR2="\[\e[48;5;28m\]"
readonly BACK_COLOR3="\[\e[48;5;34m\]"
readonly BACK_COLOR4="\[\e[48;5;0m\]"

readonly FORE_COLOR1="\[\e[38;5;255m\]"
readonly FORE_COLOR2="\[\e[38;5;22m\]"
readonly FORE_COLOR3="\[\e[38;5;28m\]"
readonly FORE_COLOR4="\[\e[38;5;34m\]"

readonly RESET="\[\e[0m\]"

# Change le prompt PS1
change_ps1() {
    PS1="${BACK_COLOR1}${FORE_COLOR1}   "
    PS1+="${BACK_COLOR2}${FORE_COLOR2}"
    PS1+="${BACK_COLOR2}${FORE_COLOR1} \u "
    PS1+="${BACK_COLOR3}${FORE_COLOR3}"
    PS1+="${BACK_COLOR3}${FORE_COLOR1} \h "
    PS1+="${BACK_COLOR4}${FORE_COLOR4}"
    PS1+="${RESET} \w > "

    LINE=$(cat <<EOF
if [ -n "\$BASH_VERSION" ] && [[ \$- == *i* ]]; then
    PS1='${PS1}'
fi
EOF
)

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

    printf "\n\n${COLOR_HIGHLIGHT_BG}"
    printf " Please restart your terminal to enabled the new prompt ${COLOR_RESET}"

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