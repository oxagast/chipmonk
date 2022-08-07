#!/bin/bash

# Warning, this code changes group permissions on /usr/bin/nut to sgid to work!

function clean_up () {
  echo "Running cleanup, killing upslog..."
  pkill upslog;
}

check_ready () {
echo "Checking if permissions are correct for functionality"
ls -al /usr/bin/upslog;
if [ $(stat -L -c "%A" /usr/bin/upslog | cut -c 7)  == "s" ];  then
if [ $(stat -c "%G" /usr/bin/upslog) == "nut" ]; then
if [ $(stat -c "%G" /var/log/ups.log) == "nut" ]; then
   trap clean_up EXIT
   log_ups
   echo "Logging UPS power details to /var/log/ups.log"
   syslog_popup
   echo "Monitoring syslog for UPS state changes"
fi
fi
else
 set_perms;
fi
}

set_perms () {
if [ $(whoami) == "root" ]; then
  echo "Adding /var/log/ups.log"
  touch /var/log/ups.log;
  chown root:nut  /var/log/ups.log
  echo "Setting group permissions on /usr/bin/upslog"
  chown root:nut /usr/bin/upslog
  chmod g+s /usr/bin/upslog
  echo "Setup Complete"
  check_ready;
else echo "You need to be root to change /usr/bin/upslog perms, sorry!"
fi;
}

function log_ups () {
echo "Starting detailed logger: /var/log/ups.log"
upslog -l /var/log/ups.log -s SK600@jerkon;
}

function syslog_popup () {
f="/var/log/syslog";
curr=$(<"$f");
inotifywait -m -e modify "$f" --format "%e" | while read -r event; do
  if [ "$event" == "MODIFY" ]; then
    prev="$curr";
    curr=$(cat "$f" | tail -n 1);
    [ "$curr" == "$prev" ] || if [ $(echo $curr | grep ": " | wc -l) -gt 0 ]; then
      powerline=$(echo $curr | grep SK600 | sed -e 's/.*UPS/UPS/')
      echo $powerline | xargs -I {X} kdialog --passivepopup {X} 30;
      echo $powerline
    fi;
  fi;
done;
}

function startup () {
echo "# # # Chipmonk # # #"
echo "NUT (Network UPS Tools) Visual Power Dialogs"
echo "Author: Marshall Whittaker / oxagast"
echo
check_ready
}

startup;
