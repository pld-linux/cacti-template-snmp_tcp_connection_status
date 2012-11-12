#!/bin/sh
#
# get number of tcp connections
# original code and xml templates by: <jbrooks@oddelement.com>
# history:
# http://cvs.pld-linux.org/cgi-bin/cvsweb.cgi/packages/cacti-template-snmp_tcp_connection_status/cacti-template-snmp_tcp_connection_status.sh
#
# Modified to use snmpget via aggregate program in snmpd side by Elan Ruusamäe <glen@pld-linux.org>, 2009-10-14
#
# To use this script, you must define in your snmpd.local.conf:
# extend .1.3.6.1.4.1.16606.1 tcpstat /usr/lib/snmpd-agent-tcpstat

PROGRAM=${0##*/}

hostname=$1
snmp_community=${2:-public}
timeout=${3:-10}
retry=5

# parse required args
if [ -z "$hostname" ]; then
	echo >&2 "Usage: $PROGRAM HOSTNAME [SNMP_COMMUNITY] [TIMEOUT]"
	exit 1
fi

# Use registered OID, http://www.oid-info.com/get/1.3.6.1.4.1.16606:
oidbase=.1.3.6.1.4.1.16606.1
oidextend=3.1.1
oidcmd='"tcpstat"'
oid=$oidbase.$oidextend.$oidcmd

out=$(snmpget -v2c -Onqv -c "$snmp_community" -t "$timeout" "$hostname" "$oid") || exit $?
# strip quotes
out=${out#\"} out=${out%\"}
echo $out
