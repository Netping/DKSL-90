#!/bin/bash
if file -sL /dev/sda4 | grep "ext4";
then mkdir /backup &&
mount /dev/sda4 /backup &&
chmod 777 -R /backup &&
echo "/dev/sda4 /backup ext4 defaults 0 0" >> /etc/fstab
	if ls /backup/ | grep NetPing;
#	then echo "@reboot bash /etc/np_scripts/rest.sh" > /var/spool/cron/crontabs/root &&
	then bash /etc/np_scripts/rest.sh &&
#	chown root:crontab /var/spool/cron/crontabs/root &&
#	chmod 600 /var/spool/cron/crontabs/root;
	cat /etc/np_scripts/crontab > /etc/crontab &&
	update-grub &&
	shutdown -r now;
	else cat /etc/np_scripts/root > /var/spool/cron/crontabs/root &&
	chown root:crontab /var/spool/cron/crontabs/root &&
	chmod 600 /var/spool/cron/crontabs/root &&
	cp -f /etc/np_scripts/np_backup.sh /backup/ &&
	mkdir /backup/tmp &&
	chmod 777 -R /backup &&
        cat /etc/np_scripts/crontab > /etc/crontab &&
	update-grub &&
	shutdown -r now;
fi
else mkfs.ext4 -F /dev/sda4 >> /dev/null &&
sleep 10 &&
mkdir /backup &&
mount /dev/sda4 /backup &&
cp -f /etc/np_scripts/np_backup.sh /backup/ &&
mkdir /backup/tmp &&
chmod 777 -R /backup &&
echo "/dev/sda4 /backup ext4 defaults 0 0" >> /etc/fstab &&
cat /etc/np_scripts/root > /var/spool/cron/crontabs/root &&
chown root:crontab /var/spool/cron/crontabs/root &&
chmod 600 /var/spool/cron/crontabs/root &&
#cp -f /etc/np_scripts/np_backup.sh /backup/ &&
cat /etc/np_scripts/crontab > /etc/crontab &&
update-grub &&
shutdown -r now;
fi
exit 0
