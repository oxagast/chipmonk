#!/bin/bash

# # # Chipmonk
# # # Author: Marshall Whittaker / oxagast
# # # NUT (Network UPS Tools) Visual Power Dialog

function playball()
{
  trap clean_up EXIT
  log_ups
  echo "Logging UPS power details to /var/log/ups.log"
  syslog_popup
  echo "Monitoring syslog for UPS state changes"
  echo
  echo "Now add this script as a startup script for your user!"
  echo
}

function clean_up()
{
  echo "Running cleanup, killing upslog..."
  pkill upslog
}

set_perms()
{
  if [ $(whoami) == "root" ]; then
    echo "Fixing permissions for first run..."
    echo "Adding /var/log/ups.log"
    touch /var/log/ups.log
    chown root:nut /var/log/ups.log
    chmod g+rw /var/log/ups.log
    echo "Setting group permissions on /usr/bin/upslog"
    chown root:nut /usr/bin/upslog
    chmod g+s /usr/bin/upslog
    echo "Setup Complete!"
    echo "Now run me as your own user!"
  else
    echo "You need to be root to change /usr/bin/upslog perms, sorry!"
  fi
}

startup()
{
  echo "Starting dialogs for $model"
  echo "Checking if permissions are correct for functionality"
  ls -al /usr/bin/upslog /var/log/ups.log
  if [ $(stat -L -c "%A" /usr/bin/upslog | cut -c 7) == "s" ]; then
    if [ $(stat -L -c "%A" /var/log/ups.log | cut -c 6) == "w" ]; then
      if [ $(stat -c "%G" /usr/bin/upslog) == "nut" ]; then
        if [ $(stat -c "%G" /var/log/ups.log) == "nut" ]; then
          playball

        fi
      fi
    fi
  else
    set_perms
  fi
}

function log_ups()
{
  echo "Starting detailed logger: /var/log/ups.log"
  upslog -l /var/log/ups.log -s $model
}

function syslog_popup()
{
  f="/var/log/syslog"
  curr=$(<"$f")
  inotifywait -m -e modify "$f" --format "%e" | while read -r event; do
    if [ "$event" == "MODIFY" ]; then
      prev="$curr"
      curr=$(cat "$f" | tail -n 1)
      [ "$curr" == "$prev" ] || if [ $(echo $curr | grep ": " | wc -l) -gt 0 ]; then
        powerline=$(echo $curr | grep $model | sed -e 's/.*UPS/UPS/')
        echo "$powerline" | xargs -I {X} kdialog --passivepopup {X} 30 2>&1 >/dev/null
        echo $powerline
      fi
    fi
  done
}

if [[ "$#" -ne 1 ]]; then
  echo "You need to specify the configured UPS model name and hostname like: "
  echo "    ./chipmonk.sh SK600@jerkon"
  exit
else
  echo "# # # Chipmonk # # #"
  echo "NUT (Network UPS Tools) Visual Power Dialogs"
  echo "Author: Marshall Whittaker / oxagast"
  echo
  model=$1
  startup
fi
