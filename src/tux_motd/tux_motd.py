#!/usr/bin/env python3

""" 
    =================================================
    Motd.tux
    =================================================
"""

import distro
import socket
import psutil
import pyfiglet
import datetime
import subprocess
import ipaddress
import glob
import yaml
import re
import netifaces
import platform
import os
import shutil

from colorama import Fore, Style

# === Paramètres =======================================================

color_critical  = Fore.RED
color_warning   = Fore.MAGENTA
color_ok        = Fore.GREEN
color_highlight = Fore.YELLOW
color_banner    = Fore.GREEN
color_title     = Fore.LIGHTWHITE_EX

reset           = Style.RESET_ALL
dim             = Style.DIM

bar_trackcolor  = Fore.LIGHTBLACK_EX
bar_symbol      = "─"
services_file   = "/etc/TUX/motd.services.txt"
font            = "termius.flf"

def print_banner(banner):
    """ Affiche une bannière via figlet """
    print(f"{color_banner}%s{reset}" % pyfiglet.figlet_format(banner, font='termius', width=1000))

def print_system():
    """ Affiche le système et sa version """

    print_label("", distro.name(), distro.version())

def print_uptime():
    """ Affiche l'uptime depuis le dernier boot """

    boot_time = psutil.boot_time()
    uptime_seconds = datetime.datetime.now().timestamp() - boot_time

    days = int(uptime_seconds // (24 * 3600))
    hours = int((uptime_seconds % (24 * 3600)) // 3600)

    print_label("", "Uptime", f"{days} {get_plural('day', days)}, {hours} {get_plural('hour', hours)}")

def print_cpu():
    """ Affiche les informations sur le/les CPU """

    print_header("CPU")

    cpu_count  = psutil.cpu_count(logical=True)
    core_count = psutil.cpu_count(logical=True) * psutil.cpu_count(logical=False)

    print(f"   . {cpu_count} {get_plural('processor', cpu_count)} / {core_count} {get_plural('total core', core_count)}\r")

def print_loadaverage():
    """ Affiche la charge CPU """

    load1, load5, load15 = psutil.getloadavg()

    cpu_count = psutil.cpu_count(logical=True)

    load1  = get_loadaverage_color(1,  load1,  cpu_count)
    load5  = get_loadaverage_color(5,  load5,  cpu_count)
    load15 = get_loadaverage_color(15, load15, cpu_count)

    print(f"     {load1}  {load5}  {load15}\r")

def get_loadaverage_color(during, value, cpu_count):
    """ Donne une couleur à la charge CPU en fonction d'un seuil """
    
    if value <= cpu_count:
       color = Fore.GREEN
    elif value <=(cpu_count * 2):
       color = Fore.MAGENTA
    else:
       color = Fore.RED

    return f"{Style.BRIGHT}{color_highlight}{during}m{reset} {color}{value:.2f}" 

def print_memory():
    """ Affiche l'état de la mémoire """

    print_header("Memory")

    mem = psutil.virtual_memory()

    render_barlabel("", "", mem.used, mem.total, 50)
    render_bargraph("", mem.used, mem.total, 70, 90, 50)

def print_disks():
    """ Affiche les disques attachés au système """

    print_header("Disks")

    exclude_prefixes = ("/snap", "/var/lib/snapd", "/run/snapd", "/System")

    for part in psutil.disk_partitions(all=False):
        try:
            if part.mountpoint.startswith(exclude_prefixes):
               continue
            usage = psutil.disk_usage(part.mountpoint)
        except PermissionError:
            continue 

        render_barlabel("", part.mountpoint, usage.used, usage.total, 50)
        render_bargraph("", usage.used, usage.total, 70, 90, 50)

def print_services():
    """ Affiche l'état de certaines services """

    try:
        with open(services_file, 'r', encoding='utf-8') as file:
            lines = [line.strip() for line in file if line.strip() and not line.strip().startswith("#")]
    except FileNotFoundError:
        return

    if not lines:
        return

    print_header(f"{'Services':36}Running ?  Enabled ?")

    for line in lines:
        name, service  = line.split(';', 1)
        if not name or not service:
            continue

        if is_service(f"{service}.service", "is-active"):
           run_status = "Yes"
           run_color  = color_ok
        else:
           run_status = "NO"
           run_color  = color_critical

        if is_service(f"{service}.service", "is-enabled"):
           boot_status = "Yes"
           boot_color  = color_ok
        else:
           boot_status = "NO"
           boot_color  = color_critical

        print(f"   {Style.BRIGHT}{color_highlight}󰒔  {name:30}{reset}{run_color}{run_status:9}  {boot_color}{boot_status}{reset}\r")

def is_service(service, state):
    """ 
        Vérifie l'état d'un service
        Args:
            service (str): Le nom du service.
            state (str): L'état à vérifier (is-active, is-enabled).
        Returns:
            bool: True si le service est dans l'état demandé, sinon False.
    """

    result = subprocess.run(["systemctl", state, "--quiet", service], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    return result.returncode ==0

def print_network():
    """ Affiche l'état du réseau """

    print_header(f"{'Network':22}{'IPv4':25}Status")
    print_interfaces()
    print("\r")
    print_gateway()
    print_dns()

def print_interfaces():
    """ Affiche les interfaces réseaux """

    interfaces = psutil.net_if_addrs()
    stats = psutil.net_if_stats()

    for iface, addrs in interfaces.items():
        if stats.get(iface) and stats[iface].isup:
           status = "Up"
           status_icon = "󰩟"
           status_color = color_ok
        else:
           status = "Down"
           status_icon = "󱦂"
           status_color = color_critical

        for addr in addrs:
            if addr.family == 2 and addr.address != '127.0.0.1':
                if addr.netmask:
                    net = ipaddress.IPv4Network(f"{addr.address}/{addr.netmask}", strict=False)
                    ip  = f"{addr.address}/{net.prefixlen}"
                else:
                    ip  = addr.address

                print(f"   {Style.BRIGHT}{color_highlight}{status_icon}  {iface:16}{reset}{ip:25}{status_color}{status}\r")

def print_gateway():
   """ Affiche la passerelle par défaut """
   gateways = netifaces.gateways()
   default = gateways.get('default', {})

   if netifaces.AF_INET in default:
       gateway, iface = default[netifaces.AF_INET]
       print_label("󱇢", "Gateway", gateway, 3)
   else:
       print_label("󱇢", "Gateway", "None", 3)

def print_dns():
    """ Affiche les DNS """

    if is_root():
        dns = set()

        for path in glob.glob('/etc/netplan/*.yaml'):
            try:
                with open(path, 'r') as file:
                    data = yaml.safe_load(file) or {}

                for section in ['ethernets', 'vlans', 'bridges', 'wifis']:
                    interfaces = data.get('network', {}).get(section, {})
                    for config in interfaces.values():
                        nameservers = config.get('nameservers', {})
                        addresses = nameservers.get('addresses', [])
                        dns.update(addresses)

            except FileNotFoundError:
                continue

        try:
            with open("/etc/resolv.conf", 'r') as file:
                for line in file:
                    match = re.match(r"nameserver\s+([\d\.]+)", line)
                    if match:
                        dns.add(match.group(1))
        except FileNotFoundError:
            pass

        if dns:
            for item in sorted(dns):
                print_label("󰖟", "DNS", item, 3)
        else:
            print_label("󰖟", "DNS", "None", 3)

def print_firewall():
    """ Affiche les règles du parefeu """

    system = platform.system()

    if (has_command("ufw") and is_root()):
        result = subprocess.run(['ufw', 'status'], stdout=subprocess.PIPE, universal_newlines=True)

        if ("---" in result.stdout):
            print_header("Firewall")

            after_separator = False
            for line in result.stdout.splitlines():
                if not after_separator:
                    if line.strip().startswith('--'):
                        after_separator = True
                    continue
                if (
                    'v6' in line or 
                    not line.strip()
                ):
                    continue
                match = re.match(r"^(\S+)", line)
                if match:
                    print_label("󰕥", match[0], "", 3)

def print_ssh():
    """ Affiche les connexions SSH """

    ssh = []

    for proc in psutil.process_iter(['pid', 'name', 'username', 'cmdline', 'create_time']):
        if proc.info['name'] == 'sshd':
            try:
                cmdline = ' '.join(proc.info.get('cmdline', []))
                if '@' in cmdline and not '[priv]' in cmdline:
                    parts = cmdline.split()
                    if len(parts) >= 2 and ':' in parts[1]:
                        user = parts[1].split(':')[1].split('@')[0]
                    else:
                        user = proc.info['username']

                    since = datetime.datetime.fromtimestamp(proc.info['create_time'])

                    for conn in proc.net_connections(kind='inet'):
                        if conn.status == psutil.CONN_ESTABLISHED and conn.laddr.port == 22 and conn.raddr:

                            remote_ip = conn.raddr.ip
                            if remote_ip.startswith('::ffff:'):
                                remote_ip = remote_ip.replace('::ffff:', '')

                            since = datetime.datetime.fromtimestamp(proc.info['create_time'])
                            ssh.append({
                                "user": user,
                                "ip": remote_ip,
                                "since": since
                            })

            except (psutil.AccessDenied, psutil.NoSuchProcess):
                continue

    if ssh:
        print_header(f"{'SSH':22}{'From IPv4':14}{'Since':11}At")

        for item in ssh:
            print_label("", item['user'], f"{item['ip']:14}{item['since'].strftime('%d/%m'):11}{item['since'].strftime('%H:%M')}", 3) 

def print_updates():
    """ Affiche les mises à jours disponibles """

    updates_file = "/var/lib/update-notifier/updates-available"

    try:
        with open(updates_file, 'r', encoding='utf-8') as file:
           content = file.read()
    except FileNotFoundError:
        return
    except PermissionError:
        return

    if not content:
        return

    total_updates    = re.search(r'^(\d+)(?= mises à jour peuvent être appliquées)', content, re.MULTILINE)
    security_updates = re.search(r'^(\d+)(?= de ces mises à jour sont des mises à jour de sécurité)', content, re.MULTILINE)

    total_updates    = int(total_updates.group(1)) if total_updates else 0
    security_updates = int(security_updates.group(1)) if security_updates else 0
    normal_updates   = total_updates - security_updates

    if total_updates:
       print_header(f"{'Updates':22}Count")
       print_label("󰏓", "System", normal_updates, 3)
       print_label("󰏓", "Security", security_updates, 3)

def render_barlabel(icon, label, used, total, width=50):
    """ Réalise le rendu des labels d'un bargraph """

    percent = int((used / total) * 100) 
    value = f"{get_size(used)} used {dim}({percent}%){reset} / {get_size(total)} total" 

    if label == "":
        print(f"   {icon}  {value}")
    else:
        print(f"   {icon}  {label:<{width - len(strip_ansi(value))}}{value}")

def render_bargraph(icon, used, total, warning, critical, width=50):
    """ Réalise le rendu d'un bargraph """

    progression  = min(int(used * 100 / total),100)
    used_width   = max(1, int(width * progression / 100))
    unused_width = width - used_width

    if progression >= critical:
        color = color_critical
    elif progression >= warning:
        color = color_warning
    else:
        color = color_ok

    print(f"   {icon}  {color}{bar_symbol * used_width}{bar_trackcolor}{dim}{bar_symbol * unused_width}{reset}\n")

def strip_ansi(text):
    """ 
        Supprime les caractères unicodes (couleur / style) 
        Args:
            text (str): La texte à modifier.
        Returns:
            str: Le texte modifié.
    """       

    import re
    return re.sub(r'\x1B\[[0-?]*[ -/]*[@-~]', '', text)

def get_size(value):
    """ 
        Donne la taille en octet avec la meilleure unité
        Args:
            value (int): La valeur en octet.
        Returns:
            str: La valeur retournée (ex. 10Mo).
    """       

    for unit in ['o', 'Ko', 'Mo', 'Go', 'To', 'Po']:
        if value < 1024:
            if unit in ['o', 'Ko', 'Mo']:
                return f"{int(value)}{unit}"
            else:
                return f"{value:.2f}{unit}"
        value /= 1024
    return f"{value:.2f}Po"

def get_plural(text, value):
    """ 
        Pluralise un texte 
        Args:
            text (str): Le mot d'origine.
            value (int): La valeur qui si supérieur à 1 ajoute un "s" au mot.
        Returns:
            str: Le mot modifié.
    """    

    return f"{text}{'s' if value > 1 else ''}"

def get_hostname():
    """ Obtient le nom court du système """

    return socket.gethostname().split('.')[0]

def print_header(title):
    """ 
        Affiche un entête 
        Args:
            title (str): Le titre.
        Returns:
            str: L'entête.    
    """

    print(f"\n{Style.BRIGHT}{color_title}{title}{reset}")

def print_label(icon, label, value, indent=0):
    """ 
        Affiche un libellé 
        Args:
            icon (str): L'îcone à afficher.
            label (str): Le libellé.
            value (str): La valeur.
            indent (int): Le nombre d'espace à gauche.
        Returns:
            str: Le libellé.
    """

    print(f"{' ' * indent}{Style.BRIGHT}{color_highlight}{icon}  {label:16}{reset}{value}")

def has_command(cmd):
    """ 
        Vérifie si une commande est disponible
        Args:
            cmd (str): Le nom de la commande.
        Returns:
            bool: True si la commande est disponible, sinon False.
    """
    return shutil.which(cmd) is not None

def is_root():
    """ 
        Vérifie si l'utilisateur courant est root
        Returns:
            bool: True si l'utilisateur est root, sinon False.
    """
    return os.geteuid() == 0

# === Fonction principale ==============================================
def main():
    print('\033[2J\033[H', end='')

    print_banner(get_hostname())
    print_system()
    print_uptime()
    print_cpu()
    print_loadaverage()
    print_memory()
    print_disks()
    print_services()
    print_network()
    print_firewall()
    print_ssh()
    print_updates()

    print('\n\n')

if __name__ == "__main__":
    main()