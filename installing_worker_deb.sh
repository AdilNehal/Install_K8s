#!/bin/bash

#Updating & Installing the Curl

# Check if the required arguments are provided
# if [ "$#" -ne 3 ]; then
#     echo "Usage: $0 <ip_of_master> <token_value> <hash_value>"
#     exit 1
# fi

# Assign the arguments to variables
# ip_of_master="$1"
# token_value="$2"
# hash_value="$3"

echo "================================= Updating & Installing the Curl ================================="
sudo apt-get update
sudo apt install -y apt-transport-https curl

#Install Containered

echo "================================= Install docker ================================= "
sudo apt install -y docker.io

echo "================================= Install Containered ================================= "
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y containerd.io

#Create containerd configuration

echo "================================= Create containerd configuration ================================= "
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

#Edit /etc/containerd/config.toml

echo "================================= Edit /etc/containerd/config.toml ================================= "
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml

#Install Kubernetes

echo "================================= Install Kubernetes ================================= "
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "================================= Disable swap ================================="
sudo swapoff -a

#modprobe br_netfilter & Edit entry in ip_forward file and change to 1

echo "================================= modprobe br_netfilter & Edit entry in ip_forward file and change to 1 ================================="
sudo modprobe br_netfilter
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.bridge.bridge-nf-call-ip6tables=1
sudo sysctl -w net.bridge.bridge-nf-call-iptables=1

# echo "================================= Joining the Master Node ================================="
# kubeadm join $ip_of_master:6443 --token $token_value \
# --discovery-token-ca-cert-hash sha256:$hash_value
