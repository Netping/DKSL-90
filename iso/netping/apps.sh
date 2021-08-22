if ls /cdrom/netping/ | grep borg
then bash /cdrom/netping/backup/preins.sh
else echo "no borg"
fi

if ls /cdrom/netping/zabbix/config/ | grep preins.sh 
then bash /cdrom/netping/zabbix/config/preins.sh
else echo "no zabbix"
fi

if ls /cdrom/netping/zabbix/config/ | grep prenps.sh 
then bash /cdrom/netping/zabbix/config/prenps.sh
else echo "no NPSettings"
fi

