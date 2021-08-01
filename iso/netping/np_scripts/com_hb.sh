if ls /dev/ | grep ttyUSB0
then touch /tmp/testcon && bash /etc/np_scripts/while.sh &
else echo "NO"
fi
