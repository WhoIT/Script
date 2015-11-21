#!/bin/bash +x

# Source: http://www.gabsoftware.com/tips/automatically-reconnect-to-your-vpn-on-linux/

# Description:
# Make the script executable "chmod +x /path/to/the/script.sh
# Put the script in .profile or .bashrc so it can be run on user login:
# Example: echo "/path/to/the/script.sh start &" >> .bashrc
# The script can be bound to shortcut keys with these commands:
#   /path/to/the/script.sh start # starts and monitors VPN connection
#   /path/to/the/script.sh stop  # stops the monitor and also the VPN connection

##########
# Config #
##########

# You can see those with "nmcli con" command
VPN_NAME="Stockholm"
VPN_UID="913ba402-1ed8-407a-915b-9d4c0b368378"

# Delay in secconds
DELAY=5

# Enable/disable ping connection check
PING_CHECK_ENABLED=false

# Check IP/Hostname
CHECK_HOST="8.8.8.8"

# Configure DISPLAY variable for desktop notifications
DISPLAY=0.0

##################
# Implementation #
##################

if [[ $1 == "stop" ]]; then
  nmcli con down uuid $VPN_UID

  echo "VPN monitoring service STOPPED!"
  echo "$(date +%Y/%m/%d\ %H:%M:%S) -> VPN monitoring service STOPPED!"
  notify-send "VPN monitoring service STOPPED!"
  
  SCRIPT_FILE_NAME=`basename $0`
  PID=`pgrep -f $SCRIPT_FILE_NAME`
  kill $PID  
elif [[ $1 == "start" ]]; then
  while [ "true" ]
  do
    VPNCON=$(nmcli con show "--active" | grep $VPN_NAME | cut -f1 -d " ")
    if [[ $VPNCON != $VPN_NAME ]]; then
      echo -e "\033[31m$(date +%Y/%m/%d\ %H:%M:%S) -> Disconnected from $VPN_NAME, trying to reconnect..."
      (sleep 1s && nmcli con up uuid $VPN_UID)
    else
      echo -e "\033[32m$(date +%Y/%m/%d\ %H:%M:%S) -> Already connected to $VPN_NAME!"
    fi
curl -s http://whatismycountry.com/ |   sed -n 's|.*,\(.*\)</h3>|\1|p'
    sleep $DELAY

    if [[ $PING_CHECK_ENABLED = true ]]; then
      PINGCON=$(ping $CHECK_HOST -c2 -q -W 3 |grep "2 received")
      if [[ $PINGCON != *2*received* ]]; then
        echo -e "\033[31m$(date +%Y/%m/%d\ %H:%M:%S) -> Ping check timeout ($CHECK_HOST), trying to reconnect..."
        (nmcli con down uuid $VPN_UID)
        (sleep 1s && nmcli con up uuid $VPN_UID)
      else
        echo -e "\033[32m$(date +%Y/%m/%d\ %H:%M:%S) -> Ping check ($CHECK_HOST) - OK!"
      fi
    fi
  done

  echo "VPN monitoring service STARTED!"
  echo "$(date +%Y/%m/%d\ %H:%M:%S) -> VPN monitoring service STARTED!"
  notify-send "VPN monitoring service STARTED!"
else 
  echo "$(date +%Y/%m/%d\ %H:%M:%S) -> Unrecognised command: $0 $@"
  echo "Please use $0 [start|stop]" 
  notify-send "UNRECOGNIZED COMMAND" "VPN monitoring service could not recognise the command!"
fi
