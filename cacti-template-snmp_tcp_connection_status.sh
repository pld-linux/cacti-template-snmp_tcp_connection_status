#!/bin/sh
#
# get number of tcp connections
# original code and xml templates by: <jbrooks@oddelement.com>
# history:
# http://cvs.pld-linux.org/cgi-bin/cvsweb.cgi/packages/cacti-template-snmp_tcp_connection_status/cacti-template-snmp_tcp_connection_status.sh
#
# Modified to use snmpd server side summary script Elan Ruusamäe <glen@pld-linux.org>

PROGRAM=${0##*/}

# parse command line args
t=$(getopt -o o: -n "$PROGRAM" -- "$@")
[ $? != 0 ] && exit $?
eval set -- "$t"

while :; do
	case "$1" in
	-o)
		snmpget=$2
		shift
	;;
	--)
		shift
		break
	;;
	*)
		echo 2>&1 "$PROGRAM: Internal error: [$1] not recognized!"
		exit 1
	;;
	esac
	shift
done

hostname=$1
snmp_community=${2:-public}
timeout=${3:-10}
retry=5

if [ -z "$hostname" -o "$hostname" = "hostcommunity" ]; then # WTF
	echo >&2 "Usage: $0 HOSTNAME [SNMP_COMMUNITY] [TIMEOUT]"
	exit 1
fi

if [ "$snmpget" ]; then
	local out
	out=$(snmpget -v2c -On -c "$snmp_community" -t "$timeout" "$hostname" "$snmpget") || exit $?
   	echo ${out#.*STRING: }
	exit 0
fi

snmpnetstat -v 2c -r "$retry" -c "$snmp_community" -t "$timeout" -Can -Cp tcp "$hostname" | awk '
	$1 == "tcp" {
		ss[$4]++;
	}

		# socket states from net-snmp-5.4.2.1/apps/snmpnetstat/inet.c
		split("CLOSED LISTEN SYNSENT SYNRECEIVED ESTABLISHED FINWAIT1 FINWAIT2 CLOSEWAIT LASTACK CLOSING TIMEWAIT", t, " ");
		# create mapping (duh, why there are different data names used?)
		# XXX TIMECLOSE missing
		split("time_close listen syn_sent syn_recv established fin_wait1 fin_wait2 closewait lastack closing time_wait", m, " ");
		for (i in t) {
			s = t[i];
			k = m[i];
			printf("%s:%d ", k, ss[s]);
		}
}'
