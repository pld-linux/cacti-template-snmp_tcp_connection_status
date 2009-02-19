#!/bin/sh
#
# get number of tcp connection
# jbrooks@oddelement.com
#
# modified to use awk and added timeout param by Elan Ruusamäe <glen@pld-linux.org>

hostname=$1
snmp_community=${2:-public}
timeout=${3:-10}
retry=5

if [ -z "$hostname" ]; then
	echo >&2 "Usage: $0 HOSTNAME [SNMP_COMMUNITY] [TIMEOUT]"
	exit 1
fi

snmpnetstat -v 2c -r "$retry" -c "$snmp_community" -t "$timeout" -Can -Cp tcp "$hostname" | awk '
	$1 == "tcp" {
		ss[$4]++;
	}

	END {
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
