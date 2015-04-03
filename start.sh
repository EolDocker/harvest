#!/bin/bash

chmod a+r /etc/resolv.conf
chmod a+r /etc/hosts
/usr/bin/supervisord
