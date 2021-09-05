echo -e "ping\nping\n" | passwd visor
cat <<EOF > /etc/netplan/00-installer-config.yaml
network:
  ethernets:
    eth0:
      dhcp-identifier: mac
      dhcp4: true
  version: 2
EOF
