#!/usr/bin/env bash
#v0.2 4d4441@gmail.com

if [ -f ver ]
then
  export $(cat ./ver | sed 's/#.*//g' | xargs)
else 
  echo "ver Environment fine not exist"
  exit 0
fi
apt update
apt install -y rsync cloud-image-utils isolinux xorriso mc netcat git
bash ./README

curdir=`pwd`
cd /tmp && rm -rf ./iso*
mkdir ./iso && chmod 777 ./iso

#mount if iso exist and download & mount iso if not exist   
if [ -f $(basename -- $UBUNTU_ISO) ]
then
  mount ./$(basename -- $UBUNTU_ISO) /mnt
else
  wget $UBUNTU_ISO
  mount ./$(basename -- $UBUNTU_ISO) /mnt
fi

rsync -av --progress /mnt/ ./iso/

#clone repo with configs and sync with iso
#git clone git@github.com:Netping/DKSL-90.git /tmp/isogit

#git clone https://github.com/Netping/DKSL-90.git /tmp/isogit
#rsync -vr /tmp/isogit/boot/iso/ /tmp/iso/

cd $curdir

rsync -vr ./iso/ /tmp/iso/
#rm -rf /tmp/isogit

cd /tmp

#postgresql 
cp /home/pgsql/*.deb /tmp/iso/netping/deb/pgsql/

#zabbix
#apt clean
#apt install --download-only -y zabbix-server-pgsql zabbix-agent zabbix-frontend-php php7.4-pgsql zabbix-nginx-conf zabbix-sql-scripts
#cp /var/cache/apt/archives/*.deb /tmp/iso/netping/deb/zabbix/
cp /home/zabbix/*.deb /tmp/iso/netping/deb/zabbix/
cp /tmp/zabbix-release_*_all.deb /tmp/iso/netping/deb/zabbix/

#dksl-90
apt clean
apt remove  -y libnl-genl-3-200 libnl-route-3-200 libnl-3-200 curl
apt install --download-only -y curl libxxhash0 fuse3 libjs-bootstrap iptables-persistent jq lm-sensors \
  crda dns-root-data dnsmasq-base fonts-glyphicons-halflings fonts-liberation iw javascript-common \
  libbluetooth3 libfuse3-3 libidn11 libjansson4 libjq1 libjs-sphinxdoc libjs-underscore \
  libmbim-glib4 libmbim-proxy libmm-glib0 libndp0 libnl-genl-3-200 libnl-route-3-200 libnl-3-200 \
  libnm0 libonig5 libpcsclite1 libqmi-glib5 libqmi-proxy libsensors-config libsensors5 libteamdctl0 \
  modemmanager netfilter-persistent network-manager network-manager-pptp ppp pptp-linux python3-msgpack \
  python3-packaging python3-pyparsing usb-modeswitch usb-modeswitch-data wireless-regdb wpasupplicant \
  iptables libip4tc2 libip6tc2 libxtables12 php-yaml
cp $curdir/../../*.deb /tmp/iso/netping/deb/updates/
#apt install --download-only -y dksl-90 ubnt-dkst54-support
cp /var/cache/apt/archives/*.deb /tmp/iso/netping/deb/updates/

VERSION=$MAJOR_VERSION.$MINOR_VERSION-$PATH_VERSION-$BUILD_VERSION$(date '+%Y-%m-%dT%H:%M:%S')
echo $VERSION > /tmp/iso/netping/np_version

mv /tmp/iso/ubuntu /tmp/
cd /tmp/iso/; find '!' -name "md5sum.txt" '!' -path "./isolinux/*" -follow -type f -exec "$(which md5sum)" {} \; > ../md5sum.txt
cd .. ; mv /tmp/md5sum.txt /tmp/iso/ ; mv /tmp/ubuntu /tmp/iso/

#combine to bootable iso 
xorriso -as mkisofs -r   -V Ubuntu\ NetpingZabbix   -o DKSL90.$VERSION.iso   -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot   -boot-load-size 4 -boot-info-table   -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot   -isohybrid-gpt-basdat -isohybrid-apm-hfsplus   -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin    iso/boot iso
