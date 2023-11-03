#!/bin/bash

exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
	echo ''
else
  sudo apt update && sudo apt install curl -y < "/dev/null"
fi
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi
sleep 1

echo -e '\e[40m\e[91m'
echo -e '  ____                  _                    '
echo -e ' / ___|_ __ _   _ _ __ | |_ ___  _ __        '
echo -e '| |   |  __| | | |  _ \| __/ _ \|  _ \       '
echo -e '| |___| |  | |_| | |_) | || (_) | | | |      '
echo -e ' \____|_|   \__  |  __/ \__\___/|_| |_|      '
echo -e '            |___/|_|                         '
echo -e '    _                 _                      '
echo -e '   / \   ___ __ _  __| | ___ _ __ ___  _   _ '
echo -e '  / _ \ / __/ _  |/ _  |/ _ \  _   _ \| | | |'
echo -e ' / ___ \ (_| (_| | (_| |  __/ | | | | | |_| |'
echo -e '/_/   \_\___\__ _|\__ _|\___|_| |_| |_|\__  |'
echo -e '                                       |___/ '
echo -e '\e[0m'
sleep 1 

sudo apt update && sudo apt install ocl-icd-opencl-dev libopencl-clang-dev libgomp1 jq -y
cd $HOME
PULSAR_LATEST_TAG=$(curl -s https://api.github.com/repos/subspace/pulsar/tags | jq -r '.[0].name')
wget -O pulsar https://github.com/subspace/pulsar/releases/download/$PULSAR_LATEST_TAG/pulsar-ubuntu-x86_64-skylake-$PULSAR_LATEST_TAG
sudo chmod +x pulsar
sudo mv pulsar /usr/local/bin/
sudo rm -rf $HOME/.config/pulsar
/usr/local/bin/pulsar init

systemctl stop subspaced subspaced-farmer &>/dev/null
rm -rf ~/.local/share/subspace*

source ~/.bash_profile
sleep 1

echo "[Unit]
Description=Subspace Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/pulsar farm --verbose
Restart=on-failure
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target" > $HOME/subspaced.service

sudo mv $HOME/subspaced.service /etc/systemd/system/
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable subspaced
sudo systemctl restart subspaced
