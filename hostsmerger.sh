#!/bin/bash
cp /etc/hosts /etc/hosts.org
if test `grep -e "# BEGIN Vagrant configuration" -e "# END Vagrant configuration" /etc/hosts | wc -l` -ne 2; then
  echo "# BEGIN Vagrant configuration" >> /etc/hosts;
  echo "# END Vagrant configuration" >> /etc/hosts;
fi

sed -i -ne '/# BEGIN Vagrant configuration/ {p; r hosts.config' -e ':a; n; /# END Vagrant configuration/ {p; b}; ba}; p' /etc/hosts
