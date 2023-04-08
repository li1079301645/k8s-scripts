#!/usr/bin/env bash
set -e

ARGS=`getopt -o h:: --long pod-cidr:,service-cidr:,help -- "$@"`

eval set -- "${ARGS}"

pod_cidr="10.10.1.0/24"

service_cidr="10.96.0.0/12"

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

sh ./components/install_containerd.sh

sh ./components/install_cni_plugins.sh

sh ./components/install_kube.sh

sh ./components/kubeadm_init.sh --pod-cidr=${pod_cidr} --service-cidr=${service_cidr}

sleep 10

sh ./components/install_flannel.sh --pod-cidr=${pod_cidr}
