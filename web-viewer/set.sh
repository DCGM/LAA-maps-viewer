#!/bin/sh
chmod uga=rwx ./files
sudo chcon -R -t httpd_sys_script_rw_t ./files
