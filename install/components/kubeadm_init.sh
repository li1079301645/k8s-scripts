#!/usr/bin/env bash
set -e

ARGS=`getopt -o h:: --long pod-cidr:,service-cidr:,help -- "$@"`

eval set -- "${ARGS}"

pod_cidr=""
service_cidr=""
while :
do
  case $1 in
    --pod-cidr)
      pod_cidr=$2
      shift
      ;;
    --service-cidr)
      service_cidr=$2
      shift
      ;;
    -h|--help)
        echo ""
        exit
        ;;
    --) shift
        break
        ;;
    *) echo "Invalid option"
        exit 1
        ;;
  esac
  shift
done

echo ">>> start run kubeadm init"

echo ">>> set pod cidr: ${pod_cidr}"

echo ">>> set service cidr: ${service_cidr}"

echo "
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta3
kubernetesVersion: v1.26.3
imageRepository: registry.aliyuncs.com/google_containers
networking:
  dnsDomain: cluster.local
  serviceSubnet: ${service_cidr}
  podSubnet: ${pod_cidr}

---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd
" > kubeadm-conf.yaml

echo '>>> disable swap'
sudo swapoff -a
sudo sed -i '/ swap / s/^(.*)$/#1/g' /etc/fstab

sudo modprobe br_netfilter
sudo echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
sudo echo 1 > /proc/sys/net/ipv4/ip_forward

sudo crictl pull registry.aliyuncs.com/google_containers/pause:3.6

sudo ctr -n k8s.io image tag --force registry.aliyuncs.com/google_containers/pause:3.6 registry.k8s.io/pause:3.6

kubeadm init --config kubeadm-conf.yaml -v6

sudo mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config