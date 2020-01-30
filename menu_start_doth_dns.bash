#!/bin/bash

# ==============================================================================
# Copyright (c) 2019 Christian Riedel
# 
# This file 'start_menu.bash' created 2019-11-29 is part of the project/program 'DoTH-DNS'.
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# 
# Github: https://github.com/Cielquan/
# ==============================================================================


err_script() {
  whiptail --msgbox "'start_doth_dns.bash' failed. You may need to restart the menu script with root privileges." 10 60 1
  exit 1
}

do_start() {
  ./start_doth_dns.bash || err_script
  whiptail --msgbox "DoTH-DNS started." 10 60 1
}

do_restart() {
  ./start_doth_dns.bash -R || err_script
  whiptail --msgbox "DoTH-DNS restarted." 10 60 1
}

do_update() {
  ./start_doth_dns.bash -U || err_script
  whiptail --msgbox "DoTH-DNS update done and restarted." 10 60 1
}

do_down() {
  ./start_doth_dns.bash -D || err_script
  whiptail --msgbox "DoTH-DNS shut down." 10 60 1
}


while true; do
  MENU=$(whiptail --title "DoTH-DNS menu" --menu "Choose an action for DoTH-DNS:" 20 60 4 --cancel-button Exit --ok-button Select\
    "1 Start DoTH-DNS" "" \
    "2 Restart DoTH-DNS" "" \
    "3 Update DoTH-DNS" "" \
    "4 Shut down DoTH-DNS" "" \
    3>&1 1>&2 2>&3)
  MENU_RV=$?
  if [ $MENU_RV -eq 0 ]; then
    case "$MENU" in
      1\ *) do_start ;;
      2\ *) do_restart ;;
      3\ *) do_update ;;
      4\ *) do_down ;;
      *) whiptail --msgbox "Programmer error: unrecognized option" 10 60 1 ;;
    esac || whiptail --msgbox "There was an error running option $MENU" 10 60 1
  else
    exit 1
  fi
done
