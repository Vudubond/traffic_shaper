#!/bin/bash
#
#  tc foloseste urmatoarele parametri.
#  kbps: Kilobytes per second
#  mbps: Megabytes per second
#  kbit: Kilobits per second
#  mbit: Megabits per second
#  bps: Bytes per second
#       Se poate folosi variabilele in:
#       kb or k: Kilobytes
#       mb or m: Megabytes
#       mbit: Megabits
#       kbit: Kilobits
#  To get the byte figure from bits, divide the number by 8 bit
#

#
# Numele si locatia comenzi de traffic control.
TC=/sbin/tc

# NIC-ul pe care dorim sa limitam banda.
IF=eth0             # Interfata

# Download limit (in Megabytes)
DNLD=1mbps          # DOWNLOAD Limit

# Upload limit (in mega bits)
UPLD=1mbps          # UPLOAD Limit

# Adresa de IP pe care dorim sa-l limitam. 
IP=xxx.xxx.xxx.xxx     # Host IP

# Regula de filtrare.
U32="$TC filter add dev $IF protocol ip parent 1:0 prio 1 u32"

start() {

# Folosim Hierarchical Token Bucket (HTB) pentru a limita banda.
# Pentru detalli sa vezi Linux man
# page.

$TC qdisc add dev $IF root handle 1: htb default 30
$TC class add dev $IF parent 1: classid 1:1 htb rate $DNLD
$TC class add dev $IF parent 1: classid 1:2 htb rate $UPLD
$U32 match ip dst $IP/32 flowid 1:1
$U32 match ip src $IP/32 flowid 1:2

# Prima linie creaza primul root qdisc, cele 2 din urma
# creaza doua child qdisc care limiteaza practic download
# si upload speed-ul.
#
# Linia 4 si 5 fac filtrul sa fie per NIC
# 'dst' pentru limitare download speed, si
# 'src' pentru limitare upload speed.

}

stop() {

# Stop - opreste shaperul
$TC qdisc del dev $IF root

}

restart() {

# Nu cred ca trebuie explicat.
stop
sleep 1
start

}

show() {

# Arata statusul aplicatiei.
$TC -s qdisc ls dev $IF
echo -n "Limita de banda in Mbit (8 Mbit = 1 MB) "
echo ""
$TC class show dev $IF

}

case "$1" in

start)

echo -n "Pornire bandwidth shaping: "
start
echo "done"
;;

stop)

echo -n "Oprire bandwidth shaping: "
stop
echo "done"
;;

restart)

echo -n "Restartare bandwidth shaping: "
restart
echo "done"
;;

show)

echo "Bandwidth shaping status for $IF:"
show
echo ""
;;

*)

pwd=$(pwd)
echo "Folosire: tc.bash {start|stop|restart|show}"
;;

esac

exit 0
