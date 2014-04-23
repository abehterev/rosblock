#!/bin/bash

/var/squidGuard/blacklists/roscom-block/xmlparser.pl > /var/squidGuard/blacklists/roscom-block/urls
/usr/bin/squidGuard -C all
/etc/init.d/squid reload

