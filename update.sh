#!/bin/bash
VERSION="1.2"

#get script path
SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
cd $SCRIPTPATH

#if not root user, restart script as root
if [ "$(whoami)" != "root" ]; then
	echo "Switching to root user..."
	sudo bash $SCRIPT $*
	exit 1
fi

shopt -s nocasematch
if ! [[ "$1" == "-noupdate" ]]; then
    echo "Performing self-update..."
    git config --global user.email "none@none.com"
    git config --global user.name "none@none.com"
    git checkout master
    git stash
    git pull
    git stash pop
    git config --global --unset user.email
    git config --global --unset user.name
    exec /bin/bash update.sh -noupdate
fi

sudo systemctl stop thermostat-daemon
sudo systemctl stop thermostat-web
sudo systemctl daemon-reload
sudo systemctl start thermostat-daemon
sudo systemctl start thermostat-web
echo 'complete'
