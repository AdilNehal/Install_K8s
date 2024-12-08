#!/bin/bash

#Updating & Installing the Curl

echo "================================= Updating & Installing the Curl ================================="
sudo apt-get update
sudo apt install -y apt-transport-https curl

#Install Containered

echo "================================= Install docker ================================= "
#sudo apt install -y docker.io
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

#Disable swap

echo "================================= Disable swap ================================="
sudo swapoff -a

#modprobe br_netfilter & Edit entry in ip_forward file and change to 1

echo "================================= modprobe br_netfilter & Edit entry in ip_forward file and change to 1 ================================="
sudo modprobe br_netfilter
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.bridge.bridge-nf-call-ip6tables=1
sudo sysctl -w net.bridge.bridge-nf-call-iptables=1


#kubeadm init

echo "================================= kubeadm init ================================="
sudo systemctl restart containerd
sleep 10s
#provision load balancer on 6443 
sudo kubeadm init --pod-network-cidr=11.244.0.0/16
echo "copy the key for the worker nodes"

#Copy to config as kubadm command says

echo "================================= Copy to config as kubadm command says ================================="
sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#taint control-plane 

echo "================================= taint control-plane   ================================="
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

#Installing Calico for the Kubernetes networking 

# echo "================================= Installing Fannel for pod networking  ================================="
# kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/v0.20.2/Documentation/kube-flannel.yml

echo "================================= Installing Calico for the Kubernetes networking  ================================="
curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/calico.yaml -O
sleep 5s
kubectl apply -f calico.yaml
echo "================================= Waiting to get the pods  ================================="
sleep 20s
# kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/custom-resources.yaml

#Check for the pods

echo "================================= Check for the pods ================================="
kubectl get pods -n kube-system




