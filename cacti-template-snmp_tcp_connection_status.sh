#!/bin/sh
# get number of tcp connection
# $1 = hostname
# $2 = snmp community

# lots of ways to do this with more style... ;)
# jbrooks@oddelement.com

# convert to use awk by Elan Ruusamäe <glen@pld-linux.org>

snmpnetstat -v 2c -c "$2" -Can -Cp tcp "$1" | awk '
	$1 == "tcp" {
		ss[$4]++;
	}

	END {
		# socket states from net-snmp-5.4.2.1/apps/snmpnetstat/inet.c
		split("CLOSED LISTEN SYNSENT SYNRECEIVED ESTABLISHED FINWAIT1 FINWAIT2 CLOSEWAIT LASTACK CLOSING TIMEWAIT", t, " ");
		# create mapping (duh, why there are different data names used?)
		# XXX TIMECLOSE missing
		split("closed listen syn_sent syn_recv established fin_wait1 fin_wait2 closewait lastack closing time_wait", m, " ");
		for (i in t) {
			s = t[i];
			k = m[i];
			printf("%s:%d ", k, ss[s]);
		}
}'
