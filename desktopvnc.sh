#!/bin/bash
apt update
DEBIAN_FRONTEND=noninteractive apt install -y kali-desktop-xfce
echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true dpkg-reconfigure lightdm
apt-get install x11vnc -y
cd /
x11vnc -storepasswd Viper1@VNC1     /etc/x11vnc.pass
#create config file for  system service
cat > /lib/systemd/system/x11vnc.service <<-EOF
[Unit]
Description="x11vnc"
Requires=display-manager.service
After=display-manager.service

[Service]
Restart=on-failure
RestartSec=5s
ExecStart=/usr/bin/x11vnc -xkb -noxrecord -noxfixes -noxdamage -display :0 -auth guess -rfbauth /etc/x11vnc.pass
ExecStop=/usr/bin/killall x11vnc

[Install]
WantedBy=multi-user.target
EOF
#restart new services &  enable on boot
systemctl daemon-reload
systemctl start x11vnc
systemctl enable x11vnc
systemctl restart lightdm
systemctl enable lightdm
