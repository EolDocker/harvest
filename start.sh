#!/bin/bash

# THESE BELONG IN THE START FILE:
# TODO: Copy in the google private key file (/google-privatekey.p12), put it in
# config dir of PHP codebase.

# TODO: change these (obviously); I am just testing.
# TODO: Not bash. I'm just testing:
# /usr/bin/docker run -d --name harvest \
/usr/bin/docker run -it --rm --name harvest \
    -p 8081:80 \
    -v /home/jrice/git/eol-base-private-cookbook/files/default/production/production.php:/var/www/eol_php_code/config/environments/production.php \
    -v /home/jrice/database.yml:/var/www/eol_php_code/config/database.yml \
  harvest bash
