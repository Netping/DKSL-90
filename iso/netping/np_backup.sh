#!/usr/bin/env bash
#v0.1 4d4441@gmail.com
VERSION="0.1"
PATH="/backup/NetPing"
BORG=/usr/local/bin/borg
PGDUMP=/usr/bin/pg_dump
PSQL=/usr/bin/psql
TYPES=(
        system
        zabbix
        database
        network
        users
)
#check arguments | show help
if [ -z "$1" ]; then
    echo -e "\nUse '$0 list|create|restore system|zabbix|database|network|users ' to run show/create/restore backups!"
    echo -e "Example:"
    echo -e "'$0 list system"
    echo -e "'$0 create zabbix"
    echo -e "'$0 restore database"
    echo -e "'$0 restore database database-YYYY-MM-DD_HH:MM:SS | use $0 list TYPE to get the NAME"
    exit 1
fi


if [ -d "$PATH" ]; then
    echo `$BORG -V`
    echo "script version "$VERSION
else
    echo "Init repo"
    $BORG init --encryption=none $PATH	
fi 


function prune() {
        TYPE=$1
        $BORG prune                 \
        --prefix=$TYPE              \
        --show-rc                   \
        --keep-daily    7           \
        --keep-weekly   4           \
        --keep-monthly  6           \
        $PATH
}

function create() {
case "$1" in
  "system")
        $BORG create                            \
        --verbose                               \
        --list                                  \
        --stats                                 \
        --show-rc                               \
        --compression lz4                       \
        --exclude-caches                        \
        --exclude '/home'                       \
        --exclude '/dev'                        \
        --exclude '/lost+found'                 \
        --exclude '/mnt'                        \
        --exclude '/cdrom'                      \
        --exclude '/proc'                       \
        --exclude '/var/run'                    \
        --exclude '/run'                        \
        --exclude '/sys'                        \
        --exclude '/tmp'                        \
        --exclude '/tmp'                        \
        $PATH'::system-{now:%Y-%m-%d_%H:%M:%S}' \
        /

        exit $?
        ;;
  "zabbix")
        /bin/su postgres -c $PGDUMP' -U postgres --clean zabbix \
        > /backup/tmp/zbxconf.sql'

        $BORG create                            \
        --verbose                               \
        --list                                  \
        --stats                                 \
        --show-rc                               \
        --compression lz4                       \
        --exclude-caches                        \
        $PATH'::zabbix-{now:%Y-%m-%d_%H:%M:%S}' \
        /etc/zabbix/                            \
        /usr/share/zabbix/modules/              \
        /backup/tmp/zbxconf.sql

        exit $?
        ;;
  "database")
        /bin/su postgres -c $PGDUMP'all -U postgres --clean > /backup/tmp/database.sql'

        $BORG create                            \
        --verbose                               \
        --list                                  \
        --stats                                 \
        --show-rc                               \
        --compression lz4                       \
        --exclude-caches                        \
        $PATH'::database-{now:%Y-%m-%d_%H:%M:%S}' \
        /backup/tmp/database.sql

        exit $?
        ;;
  "network")
        $BORG create                            \
        --verbose                               \
        --list                                  \
        --stats                                 \
        --show-rc                               \
        --compression lz4                       \
        --exclude-caches                        \
        $PATH'::network-{now:%Y-%m-%d_%H:%M:%S}' \
        /etc/netplan/

        exit $?
        ;;
  "users")
        $BORG create                            \
        --verbose                               \
        --list                                  \
        --stats                                 \
        --show-rc                               \
        --compression lz4                       \
        --exclude-caches                        \
        $PATH'::users-{now:%Y-%m-%d_%H:%M:%S}'  \
        /etc/shadow                             \
        /etc/gshadow                            \
        /etc/passwd                             \
        /etc/group

        exit $?
        ;;
  *)
        echo -e "Unrecognized argument."
        exit $?
        ;;
esac
}


function restore() {
case "$1" in
  "system")
        if [ -z "$2" ]; then
                LAST=`$BORG list --short --prefix=system --last 1 $PATH`
        else
                LAST=$2
        fi

        cd / && $BORG extract $PATH'::'$LAST

        exit $?
        ;;
  "zabbix")
        if [ -z "$2" ]; then
                LAST=`$BORG list --short --prefix=zabbix --last 1 $PATH`
        else
                LAST=$2
        fi

        cd / && $BORG extract $PATH'::'$LAST

        /bin/su postgres -c $PSQL' -U postgres -d zabbix -f /backup/tmp/zbxconf.sql'

        exit $?
        ;;
  "database")
        if [ -z "$2" ]; then
                LAST=`$BORG list --short --prefix=database --last 1 $PATH`
        else
                LAST=$2
        fi

        cd / && $BORG extract $PATH'::'$LAST

        /bin/su postgres -c $PSQL' -U postgres -f /backup/tmp/database.sql'

        exit $?
        ;;
  "network")
        if [ -z "$2" ]; then
                LAST=`$BORG list --short --prefix=network --last 1 $PATH`
        else
                LAST=$2
        fi

        cd / && $BORG extract $PATH'::'$LAST

        exit $?
        ;;
  "users")
        if [ -z "$2" ]; then
                LAST=`$BORG list --short --prefix=users --last 1 $PATH`
        else
                LAST=$2
        fi

        cd / && $BORG extract $PATH'::'$LAST

        exit $?
        ;;
  *)
        echo -e "Unrecognized argument."
        exit $?
        ;;
esac
}

case "$1" in
  "list")
        TYPE=$2
        $BORG list --prefix=$TYPE $PATH
        exit $?
        ;;
  "create")
        TYPE=$2
        create $TYPE
        ;;
  "restore")
        TYPE=$2
        NAME=$3
        if [ -z "$3" ]; then
                restore $TYPE
        else
                restore $TYPE $NAME
        fi
        exit $?
        ;;
  "prune")
        for TYPE in "${TYPES[@]}"; do
        prune $TYPE
        done
        exit $?
        ;;
  *)
        echo -e "Unrecognized argument."
        exit 1
        ;;
esac
