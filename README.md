# motd.tux

curl https://raw.githubusercontent.com/ajenti/ajenti/master/scripts/install-venv.sh | sudo bash -s -


**VSCode**
Installer l'extension "Remote - SSH"

Générer une clé RSA. Ex:

    cd .ssh
    ssh-keygen -t rsa -b 4096 -C "jquintard"

Modifier/créer le fichier ~/.ssh/config avec l'hôte sur lequel se connecter. Ex:

    Host jeq-ubuntu20-01
      HostName 10.211.55.12
      User jquintard
      Port 22
      IdentityFile ~/.ssh/jquintard_rsa

Copier la clé sur la machine distante. Ex:
    ssh-copy-id -i jquintard_rsa.pub jquintard@10.211.55.12

Se connecter depuis VSCode via le menu ><

Enregistrer les credentials (après une première fois)
git config --global credential.helper store

**Installation**
sudo -i
git clone https://yeraz-repos@dev.azure.com/yeraz-repos/Tux/_git/Tux /opt/TUX/packages
cd /opt/TUX/packages
source install.sh

**Mise à jour**
cd /opt/TUX/packages
git pull 

**Activer VENV pour dev/test**
cd /opt/TUX/packages
source venv-activate.sh

**Scripts**
./src/motd/motd.py

**Debug de Motd**
tux_motd 2> /tmp/tuxmotd.log