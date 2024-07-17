#! /bin/sh
#

lan=`/etc/dksl-90-vars lan`
dkst=`/etc/dksl-90-vars dkst`

nmcli conn add type ethernet ifname $lan con-name $lan ipv4.method auto
nmcli conn add type ethernet ifname $dkst con-name $dkst ipv4.method manual ipv4.address 192.168.168.1/24
sed -i '/\@reboot bash \/etc\/NetworkManager\/configure\.sh/d' /var/spool/cron/crontabs/root
exit 0
