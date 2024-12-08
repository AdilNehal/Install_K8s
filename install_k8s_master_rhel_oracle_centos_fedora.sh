#!/bin/bash

echo "================================= Install Containered ================================= "
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y containerd.io
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd


echo "================================= Set SELinux to permissive mode ================================= "
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

echo "================================= Edit /etc/containerd/config.toml ================================= "
sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml

echo "================================= Adding Kubernetes packages ================================= "

echo "======== prod ======"

cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet

#Disable swap

echo "================================= Disable swap ================================="
swapoff -a

#modprobe br_netfilter & Edit entry in ip_forward file and change to 1

echo "================================= modprobe br_netfilter & Edit entry in ip_forward file and change to 1 ================================="
modprobe br_netfilter
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.bridge.bridge-nf-call-ip6tables=1
sysctl -w net.bridge.bridge-nf-call-iptables=1

#kubeadm init

echo "================================= kubeadm init ================================="
systemctl restart containerd
sleep 10s
#provision load balancer on 6443 
kubeadm init --pod-network-cidr=172.10.0.0/16
echo "copy the key for the worker nodes"

#Copy to config as kubadm command says

echo "================================= Copy to config as kubadm command says ================================="
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "================================= taint control-plane   ================================="
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

echo "================================= Installing Calico for the Kubernetes networking  ================================="
curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/calico.yaml -O
sleep 5s
kubectl apply -f calico.yaml
echo "================================= Waiting to get the pods  ================================="
sleep 20s

#Check for the pods

echo "================================= Check for the pods ================================="
kubectl get pods -n kube-system
