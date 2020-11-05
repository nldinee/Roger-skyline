#!/bin/bash
# FILE: /etc/scripts/cronMonitor.sh
SUM_COPY="/var/tmp/checksum"
CRON_FILE="/etc/crontab"
SUM=$(sudo md5sum $CRON_FILE)
if [ ! -f $SUM_COPY ]
then
echo "$SUM" > $SUM_COPY
exit 0;
fi;
if [ "$SUM" != "$(cat $SUM_COPY)" ];
then
echo "$SUM" > $SUM_COPY
echo "$CRON_FILE has been modified ! '*_*" | mail -s "$CRON_FILE modified !" root@debian
fi;
