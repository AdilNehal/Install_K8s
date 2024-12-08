# Reset Kubernetes and remove related files
sudo kubeadm reset

# Remove the Kubernetes configuration folder
sudo rm -rf ~/.kube

# Remove Docker and Containerd packages
sudo yum remove -y docker-ce docker-ce-cli containerd.io
sudo yum remove containerd.io runc

# Remove Kubernetes packages
sudo yum remove -y kubelet kubeadm kubectl

# Remove Kubernetes configuration files
sudo rm -rf /etc/kubernetes

# Remove CNI configuration files
sudo rm -rf /etc/cni

# Remove etcd data directory
sudo rm -rf /var/lib/etcd/

# Remove Docker GPG key (if it was added)
sudo rm -rf /etc/apt/keyrings/docker.gpg

# Clean up yum cache (optional but recommended)
sudo yum clean all
sudo yum makecache
