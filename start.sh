#!/bin/bash

chmod a+r /etc/resolv.conf
chmod a+r /etc/hosts
# New bug, after we added quartley RHEL patches, Apr 2015:
chmod a+rx /
/usr/bin/supervisord
