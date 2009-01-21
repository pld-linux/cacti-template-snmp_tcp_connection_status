#/bin/bash

# get number of tcp connection
# $1 = hostname
# $2 = snmp community
# lots of ways to do this with more style... ;)
# jbrooks@oddelement.com

CACTIDIR=/var/www/htdocs/cacti/scripts
TMPDIR=/tmp

cd $CACTIDIR


snmpnetstat -v 2c -c $2 -Can -Cp tcp $1 > $TMPDIR/$1

ESTABLISHED=`grep ESTABLISHED $TMPDIR/$1 |wc -l`
LISTENING=`grep LISTEN $TMPDIR/$1 |wc -l`
TIME_WAIT=`grep TIMEWAIT $TMPDIR/$1 |wc -l`
TIME_CLOSE=`grep TIMECLOSE $TMPDIR/$1 |wc -l`
FIN1=`grep FINWAIT1 $TMPDIR/$1 |wc -l`
FIN2=`grep FINWAIT2 $TMPDIR/$1 |wc -l`
SYNSENT=`grep SYNSENT $TMPDIR/$1 |wc -l`
SYNRECV=`grep SYNRECV $TMPDIR/$1 |wc -l`

echo -n established:${ESTABLISHED} listen:${LISTENING} time_wait:${TIME_WAIT} time_close:${TIME_CLOSE} syn_sent:${SYNSENT} fin_wait1:${FIN1} fin_wait2:${FIN2} syn_recv:${SYNRECV}

# uncomment for debugging:
# echo $1: established:$ESTABLISHED listen:$LISTENING time_wait:$TIME_WAIT time_close:$TIME_CLOSE syn_sent:$SYN fin_wait1:$FIN1 fin_wait2:$FIN2 >> $TMPDIR/tcp.log

# may want to comment this for debugging too
rm $TMPDIR/$1
