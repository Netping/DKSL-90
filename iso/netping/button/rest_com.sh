echo -e "ping\nping\n" | passwd visor
cat <<EOF > /etc/netplan/netplan.yaml
network:
  ethernets:
    eth0:
      dhcp-identifier: mac
      dhcp4: true
    eth1:
      dhcp-identifier: mac
      dhcp4: true
    toDKST:
      dhcp4: false
      addresses: [192.168.5.99/24]
  version: 2
EOF
