BORG_VERSION="https://github.com/borgbackup/borg/releases/download/1.1.16/borg-linux64"
#download borg_backup
if [ -f $(basename -- $BORG_VERSION) ]
then
  cp ./$(basename -- $BORG_VERSION) ./iso/netping/borg
else
  wget $BORG_VERSION
  cp ./$(basename -- $BORG_VERSION) ./iso/netping/borg
fi
