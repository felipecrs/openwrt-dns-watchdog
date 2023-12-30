#!/bin/sh

set -eux

service dns_watchdog stop || true
service dns_watchdog disable || true

rm -f /etc/init.d/dns_watchdog /var/dns_watchdog.sh /etc/config/dns_watchdog
