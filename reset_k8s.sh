#!/bin/bash

sudo kubeadm reset
sudo rm -rf ~/.kube
sudo rm -rf /etc/docker
sudo apt-get purge -y docker.io
sudo apt-get purge -y containerd.io
sudo apt-get remove -y containerd.io
sudo apt-get purge kubeadm kubectl kubelet
sudo rm -rf /etc/kubernetes
sudo rm -rf /etc/cni
sudo rm -rf /var/lib/etcd/
sudo rm -rf /etc/apt/keyrings/docker.gpg
