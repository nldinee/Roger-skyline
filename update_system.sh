#!/bin/bash


echo "[+] System was updated on $(date)" >> /var/log/update_script.log
apt-get update -y >> /var/log/update_script.log
apt-get upgrade -y >> /var/log/update_script.log
