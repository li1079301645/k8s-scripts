#!/usr/bin/env bash
set -e

sh ./components/install_containerd.sh

sh ./components/install_kube.sh

