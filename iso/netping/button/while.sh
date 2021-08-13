cat < /dev/ttyUSB0 >> /tmp/testcon &
sleep 5
#while [ condition ]
while :
do
echo "ON" >> /dev/ttyUSB0
sleep 5
if cat /tmp/testcon | grep ON
then bash /etc/np_scripts/rest_com.sh && break
else echo "NO" > /dev/null
fi
done
