# Create configuration file for containerd:

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# Load modules:

sudo modprobe overlay
sudo modprobe br_netfilter

# Set system configurations for Kubernetes networking:

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply new settings:

sudo sysctl --system

# Add Docker’s official GPG key:

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Use the following command to set up the repository:

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install containerd. Note: use the following command "sudo kill -9 $( sudo lsof /var/lib/dpkg/lock-frontend | awk '{ print $2 }' | tail -1 )" if you receive a "E: Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), is another process using it?" message.

sudo apt-get update && sudo apt-get install -y containerd.io

# Create default configuration file for containerd:

sudo mkdir -p /etc/containerd

# Generate default containerd configuration and save to the newly created default file:

sudo containerd config default | sudo tee /etc/containerd/config.toml

# Restart containerd to ensure new configuration file usage:

sudo systemctl restart containerd

# Verify that containerd is running:

sudo systemctl status containerd

# Disable swap:

sudo swapoff -a
