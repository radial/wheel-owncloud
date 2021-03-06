#!/bin/bash
set -e

# Tunable settings
OWNCLOUD_VERSION=${OWNCLOUD_VERSION:-7.0.2}
WWW_DIR=${WWW_DIR:-/data/www}

# Misc settings
ERR_LOG=/log/$HOSTNAME/ocApp_stderr.log

restart_message() {
    echo "Container restart on $(date)."
    echo -e "\nContainer restart on $(date)." | tee -a $ERR_LOG
}

# create dirs if needed
mkdir -p $WWW_DIR

# initialize folders if needed
if [ ! "`ls -A $WWW_DIR`" ] ; then
    # download source
    wget -q -O - https://download.owncloud.org/community/owncloud-"$OWNCLOUD_VERSION".tar.bz2 | tar jx -C $WWW_DIR &&
    echo "Owncloud version $OWNCLOUD_VERSION has been downloaded to $WWW_DIR"

    chmod -v 700 $WWW_DIR
    chown -R www-data:www-data $WWW_DIR

    ln -s $WWW_DIR/owncloud-data/data/owncloud.log /log/$HOSTNAME/owncloud.log
else
    restart_message
fi

exec /usr/sbin/php5-fpm \
    -c /config/php5/fpm/php.ini \
    --fpm-config /config/php5/fpm/php-fpm.conf \
    --nodaemonize
