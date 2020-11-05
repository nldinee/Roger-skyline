#!/bin/bash

echo "@reboot /home/nabdelba/scripts/update_system.sh" | crontab -
echo "0 4 * * 6 /home/nabdelba/scripts/update_system.sh" | crontab -

