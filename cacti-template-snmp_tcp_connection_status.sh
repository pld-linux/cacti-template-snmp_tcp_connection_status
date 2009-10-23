#!/bin/sh
#
# get number of tcp connections
# original code and xml templates by: <jbrooks@oddelement.com>
# history:
# http://cvs.pld-linux.org/cgi-bin/cvsweb.cgi/packages/cacti-template-snmp_tcp_connection_status/cacti-template-snmp_tcp_connection_status.sh
#
# Modified to use snmpd server side summary script Elan Ruusamäe <glen@pld-linux.org>

PROGRAM=${0##*/}

hostname=$1
snmp_community=${2:-public}
timeout=${3:-10}
retry=5
oid=.1.3.6.1.4.1.16606.1.3.1.1.7.116.99.112.115.116.97.116

# handle case when template was imported with <> getting lost
if [ -z "$hostname" -o "$hostname" = "hostcommunity" ]; then # WTF
	echo >&2 "Usage: $PROGRAM HOSTNAME [SNMP_COMMUNITY] [TIMEOUT]"
	exit 1
fi

out=$(snmpget -v2c -On -c "$snmp_community" -t "$timeout" "$hostname" "$snmpget") || exit $?
echo ${out#.*STRING: }
exit 0
