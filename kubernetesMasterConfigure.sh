kubeadm init --pod-network-cidr=10.244.0.0/16
#Copy kubeadm Join command
#Exit Sudo
su <normal user>
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
#Deploy Flannel
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel-old.yaml
#Check cluster state
kubectl get pods --all-namespaces

#kubadm join command to be run on nodes with sudo

