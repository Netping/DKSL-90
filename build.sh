#!/usr/bin/env bash
#v0.1 4d4441@gmail.com

if [ -f .iso ]
then
  export $(cat .iso | sed 's/#.*//g' | xargs)
else 
  echo ".iso Environment fine not exist"
  exit 0
fi
apt update
apt install -y rsync cloud-image-utils isolinux xorriso mc netcat git

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
git clone git@github.com:Netping/DKSF_90.git ./isogit

rsync -vr ./isogit/iso/ ./iso/
#rm -rf ./isogit 

#download borg_backup
if [ -f $(basename -- $BORG_VERSION) ]
then
  cp ./$(basename -- $BORG_VERSION) ./iso/netping/borg
else
  wget $BORG_VERSION
  cp ./$(basename -- $BORG_VERSION) ./iso/netping/borg
fi

#clone repo with NpServerSettings
git clone git@github.com:Netping/DKST90_NpServerSettings.git ./iso/netping/zabbix/NpServerSettings

#download and install zabbix repo 
if [ -f $(basename -- $ZABBIX_VERSION) ]
then
  apt install ./$(basename -- $ZABBIX_VERSION)
else
  wget $ZABBIX_VERSION
  apt install ./$(basename -- $ZABBIX_VERSION)
fi

#zabbix
apt clean
apt install --download-only -y zabbix-server-pgsql zabbix-frontend-php php7.4-pgsql zabbix-nginx-conf zabbix-agent
cp /var/cache/apt/archives/*.deb ./iso/netping/deb/zabbix/
cp ./zabbix-release_*_all.deb ./iso/netping/deb/zabbix/

#postgresql 
apt clean
apt install --download-only -y postgresql
cp /var/cache/apt/archives/*.deb ./iso/netping/deb/pgsql

VERSION=$MAJOR_VERSION.$MINOR_VERSION.$PATH_VERSION.$BUILD_VERSION$(date '+%Y-%m-%dT%H:%M:%S')
echo $VERSION > ./iso/netping/np_version

#sql pgdb files 
cp -r ./sql ./iso/netping/


mv ./iso/ubuntu ./
cd ./iso/; find '!' -name "md5sum.txt" '!' -path "./isolinux/*" -follow -type f -exec "$(which md5sum)" {} ; > ../md5sum.txt
cd .. ; mv ./md5sum.txt ./iso/ ; mv ./ubuntu ./iso/

#combine to bootable iso 
xorriso -as mkisofs -r   -V Ubuntu\ NetpingZabbix   -o DKSL90.$VERSION.iso   -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot   -boot-load-size 4 -boot-info-table   -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot   -isohybrid-gpt-basdat -isohybrid-apm-hfsplus   -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin    iso/boot iso

