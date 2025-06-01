# TUX

![alt text](/ressources/screenshot.jpg)

**Installation**
<pre>
sudo -i
git clone https://github.com/YerazLab/TUX.git /opt/TUX/packages
cd /opt/TUX/packages
source install.sh
</pre>

**Parameters**

| Option      | Description                                      |
|-------------|--------------------------------------------------|
| `--silent`  | Disable all questions and enable all features    |
| `--help`    | Show usage and exit                              |

**Update**
<pre>
cd /opt/TUX/packages
git pull
</pre>

**Activate VENV**
<pre>
cd /opt/TUX/packages
source venv-activate.sh
</pre>


**Debug de tux_motd**
<pre>
tux_motd 2> /tmp/tuxmotd.log
</pre>

