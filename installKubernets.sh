sudo swapoff -a
sudo apt update && sudo apt install -y apt-transport-https-curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt update
sudo apt install -y kubeadm kubelet kubectl
#Next line to disable auto updates on packages
#sudo apt mark hold kubeadm kubelet kubectl
