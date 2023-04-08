#!/usr/bin/env bash
set -e

containerd_config_file=/etc/containerd/config.toml

echo ">>> start install containerd"
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo mkdir -m 0755 -p /etc/apt/keyrings
sudo rm -rf /etc/apt/keyrings/docker.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt-get update
sudo apt-get install containerd.io

echo ">>> config containerd"
crictl config runtime-endpoint unix:///var/run/containerd/containerd.sock

mkdir /etc/containerd/certs.d/docker.io -pv
cat > /etc/containerd/certs.d/docker.io/hosts.toml << EOF
server = "https://docker.io"
[host."https://7j92b246.mirror.aliyuncs.com"]
  capabilities = ["pull", "resolve"]
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now containerd

echo ">>> save containerd configuration file to ${containerd_config_file}"
sudo containerd config default > ${containerd_config_file}
sudo systemctl restart containerd