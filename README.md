# TUX

**Installation**
sudo -i
git clone https://yeraz-repos@dev.azure.com/yeraz-repos/Tux/_git/Tux /opt/TUX/packages
cd /opt/TUX/packages
source install.sh

**Update**
cd /opt/TUX/packages
git pull 

**Activate VENV**
cd /opt/TUX/packages
source venv-activate.sh

**Debug de tux_motd**
tux_motd 2> /tmp/tuxmotd.log