#!/bin/bash

ufw status
ufw enable

ufw allow 1338/tcp # custom ssh port
ufw allow 80/tcp # http 
ufw allow 433 # https 
