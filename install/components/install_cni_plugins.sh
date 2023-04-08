#!/usr/bin/env bash
set -e

cni_plugins_version=v1.2.0
cni_plugins=cni-plugins-linux-amd64-${cni_plugins_version}.tgz
echo ">>> download CNI Plugins ${cni_plugins}"
if [ ! -f "${cni_plugins}" ]; then
    sudo rm -rf ${cni_plugins}
    wget https://github.com/containernetworking/plugins/releases/download/${cni_plugins_version}/${cni_plugins}
else
    echo "existed, skip to download"
fi

echo ">>> install CNI Plugins"
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin ${cni_plugins}

sudo rm -rf ${cni_plugins}