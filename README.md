# openwrt-dns-watchdog

Monitors a preferred DNS server and switches to a backup DNS server if the preferred server is not responding. And switches back to the preferred DNS server when it is responding again.

Useful if you are running AdGuard Home on another device and want to use it as your primary DNS server. But if that device is not available, you don't want to be without DNS.

https://github.com/felipecrs/openwrt-dns-watchdog/assets/29582865/1561d5a2-ffe0-4fa4-a95c-e9493a15130d

## Installing

```console
curl -fsSL https://github.com/felipecrs/openwrt-dns-watchdog/raw/master/install.sh |
    ssh root@192.168.1.1 sh -s -- \
    192.168.1.10 1.1.1.1,1.0.0.1 10s
```

The script takes 3 arguments:

1. The IP address of the preferred DNS server
2. The IP addresses of the backup DNS servers, comma separated
3. The interval to check the preferred DNS server, in seconds. This is optional and defaults to 10 seconds.

You can then check the logs of the service with:

```console
ssh root@192.168.1.1 logread -f -e dns-watchdog
```

Try restarting the preferred DNS server, you should then see something like this in the logs:

```console
Sat Dec 30 15:54:16 2023 daemon.err dns_watchdog.sh[3931]: DNS set to '1.1.1.1 1.0.0.1'
Sat Dec 30 15:54:21 2023 daemon.err dns_watchdog.sh[3931]: DNS set to '192.168.1.10'
```

## Configuring

You can either re-run the install script with the new arguments, or use `uci` to change the configuration:

```console
$ ssh root@192.168.1.1

$ uci set dns_watchdog.dns_watchdog.preferred_dns=192.168.1.10
$ uci set dns_watchdog.dns_watchdog.backup_dns=1.1.1.1,1.0.0.1
$ uci set dns_watchdog.dns_watchdog.every=10s

$ uci commit dns_watchdog

$ service dns_watchdog reload
```

## Updating

Simply follow the installation instructions again.

## Uninstalling

```console
curl -fsSL https://github.com/felipecrs/openwrt-dns-watchdog/raw/master/install.sh |
    ssh root@192.168.1.1 sh
```
