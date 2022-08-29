#! usr/bin/bash

echo "cloning git"
git clone https://github.com/waleedzafar68/vulnerablewp.git
echo "Changing Directory"
cd vulnerablewp
echo "Running apt update"
sudo apt update && sudo apt install docker-compose -y
echo "Running docker containers"
docker-compose up -d
