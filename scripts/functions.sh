color_ok_fg="\e[32m"
color_ok_bg="\e[42m\e[30m"
color_critical_fg="\e[31m"
color_critical_bg="\e[41m\e[30m"
highlight_color_fg="\e[1m\e[93m"
highlight_color_bg="\e[43m\e[30m"
msg_width="10"
reset="\e[0m"

# Affiche un message
print_msg() {
    if [[ $1 == "OK" ]]; then
        local color1=$color_ok_bg
        local color2=$color_ok_fg
    else
        local color1=$color_critical_bg
        local color2=$color_critical_fg
    fi

    local label="$2"
    local label_len=${#label}+2
    local pad=$(($msg_width - label_len))
    (( pad < 1 )) && pad=1

    printf "${color1} ${label} ${reset}%*s${color2}${3}${reset}\n" "$pad"
}

print_header() {
    printf "\n${highlight_color_fg}${1}${reset}\n\n"
}

# Gère l'état de retour succès
set_success() {
    print_msg "OK" "$1" "$2"
    rm -f tux_error.log
    return 0
}

# Gère l'état de retour erreur
set_error() {
    print_msg "ERROR" "$1" "$2"
    printf "\n\n"
    cat tux_error.log
    rm -f tux_error.log
    return 1
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
        printf "In order to run in as root use :\n\n"
        printf "${color_ok_fg}sudo -i${reset}\n"
        printf "${color_ok_fg}source install.sh${reset}\n"
        
        return 1
    else
        print_msg "OK" "SCRIPT" "Script run with root privileges"
        return 0
    fi
}

# Verifie si un script est exécute ou sourcé
check_issourced() {
    is_sourced
    if [ $? -eq 0 ]; then
        print_msg "ERROR" "SCRIPT" "The script is being executed not sourced"
        printf "\n\n"
        printf "In order to run this script as sourced, use :\n\n"
        printf "${color_ok_fg}source install.sh${reset}\n"
        
        return 1
    else 
        print_msg "OK" "SCRIPT" "Script is correctly sourced"
        return 0
    fi
}

# Vérifie si une comande existe
has_command() {
  command -v "$@" >/dev/null 2>&1
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

#Affiche un dialogue oui/non
dialog() {
    local selected=0
    printf "\n\n"
    printf '\e[?25l'

    draw_choices() {
        printf "\r"
        if (( selected == 0 )); then
            printf "${color_ok_bg} ${1} ${reset}  "
            printf "${color_critical_fg}${2}${reset}"
        else
            printf "${color_ok_fg}${1}${reset}  "
            printf "${color_critical_bg} ${2} ${reset}"
        fi
    }

    draw_choices $*

    while :; do
        IFS= read -rsn1 key
        case "$key" in
            $'\x1b')
                read -rsn2 key2
                key+="$key2"
                case "$key" in
                    $'\x1b[D')
                        selected=0
                        draw_choices $*
                        ;;
                    $'\x1b[C')
                        selected=1
                        draw_choices $*
                        ;;
                esac
                ;;
            "")
                printf "\n"
                printf '\e[?25h'
                if (( selected == 0 )); then
                    REPLY="1"
                else
                    REPLY="0"
                fi
                break
                ;;
        esac
    done
}

# Quitte l'installation proprement
quit_installation() {
    printf "\n\n"
    print_msg "ERROR" "Installation error"
    printf "\n\n"

    if [ -n "$VIRTUAL_ENV" ]; then
        deactivate
    fi

    is_sourced
    if [ $? -eq 1 ]; then
        return 1
    else
        exit 1
    fi
}

# Affiche le message de démarrage
start_message() {
    printf "${highlight_color_fg}"
    printf "▗▄▄▄▖▗▖ ▗▖▗▖  ▗▖    ▗▄▄▄▖▗▖  ▗▖ ▗▄▄▖▗▄▄▄▖ ▗▄▖ ▗▖   ▗▖    ▗▄▖ ▗▄▄▄▖▗▄▄▄▖ ▗▄▖ ▗▖  ▗▖\n"
    printf "  █  ▐▌ ▐▌ ▝▚▞▘       █  ▐▛▚▖▐▌▐▌     █  ▐▌ ▐▌▐▌   ▐▌   ▐▌ ▐▌  █    █  ▐▌ ▐▌▐▛▚▖▐▌\n"
    printf "  █  ▐▌ ▐▌  ▐▌        █  ▐▌ ▝▜▌ ▝▀▚▖  █  ▐▛▀▜▌▐▌   ▐▌   ▐▛▀▜▌  █    █  ▐▌ ▐▌▐▌ ▝▜▌\n"
    printf "  █  ▝▚▄▞▘▗▞▘▝▚▖    ▗▄█▄▖▐▌  ▐▌▗▄▄▞▘  █  ▐▌ ▐▌▐▙▄▄▖▐▙▄▄▖▐▌ ▐▌  █  ▗▄█▄▖▝▚▄▞▘▐▌  ▐▌\n"
    printf "${reset}\n\n"
}