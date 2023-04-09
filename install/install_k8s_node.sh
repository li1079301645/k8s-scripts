#!/usr/bin/env bash
set -e

sh ./components/install_containerd.sh

sh ./components/install_kube.sh

echo '>>> disable swap'
sudo swapoff -a
sudo sed -i '/ swap / s/^(.*)$/#1/g' /etc/fstab

sudo modprobe br_netfilter
sudo echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
sudo echo 1 > /proc/sys/net/ipv4/ip_forward

sudo crictl pull registry.aliyuncs.com/google_containers/pause:3.6

sudo ctr -n k8s.io image tag --force registry.aliyuncs.com/google_containers/pause:3.6 registry.k8s.io/pause:3.6


