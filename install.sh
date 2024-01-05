#!/bin/sh

set -eux

preferred_dns="${1}"
backup_dns="${2}"
every="${3:-"10s"}"

tee /etc/config/dns_watchdog >/dev/null <<EOF
config dns_watchdog 'dns_watchdog'
  option preferred_dns '${preferred_dns}'
  option backup_dns '${backup_dns}'
  option every '${every}'
EOF

tee /usr/bin/dns_watchdog >/dev/null <<'EOF'
#!/bin/sh

set -eu

preferred_dns="$(uci get dns_watchdog.dns_watchdog.preferred_dns)"
backup_dns="$(uci get dns_watchdog.dns_watchdog.backup_dns)"
# replace commas with spaces
backup_dns="$(echo "${backup_dns}" | tr ',' ' ')"
every="$(uci get dns_watchdog.dns_watchdog.every)"

uci set network.wan.peerdns="0"
uci commit network
service network reload

set_dns() {
  if nslookup -timeout=1 -retry=1 localhost "${preferred_dns}" >/dev/null 2>&1; then
    dns_to_set="${preferred_dns}"
  else
    dns_to_set="${backup_dns}"
  fi

  current_dns="$(uci get network.wan.dns)"
  if [ "${current_dns}" != "${dns_to_set}" ]; then
    uci set network.wan.dns="${dns_to_set}"
    uci commit network
    service network reload
    echo "DNS set to '${dns_to_set}'" >&2
  fi
}

set_dns
while sleep "${every}"; do
  set_dns
done
EOF

chmod +x /usr/bin/dns_watchdog

tee /etc/init.d/dns_watchdog >/dev/null <<EOF
#!/bin/sh /etc/rc.common

USE_PROCD=1

START=99
STOP=01

start_service() {
  procd_open_instance
  procd_set_param command /usr/bin/dns_watchdog
  procd_set_param file /etc/config/dns_watchdog
  procd_set_param stdout 1
  procd_set_param stderr 1
  procd_close_instance
}
EOF

chmod +x /etc/init.d/dns_watchdog

tee /lib/upgrade/keep.d/dns_watchdog >/dev/null <<EOF
/usr/bin/dns_watchdog
/etc/init.d/dns_watchdog
/etc/config/dns_watchdog
EOF

service dns_watchdog enable
service dns_watchdog reload
service dns_watchdog status
