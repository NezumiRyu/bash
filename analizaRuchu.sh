#!/bin/bash

function mgrep { #$1 = szukane, $2 = plik
	if test "${2: -3}" = ".gz"
	then #gz
		zgrep "$1" $2
	else
		grep "$1" $2
	fi
}

if [ "$#" -lt "1" ] || [ "$1" = "" ]
then
	echo "$0 \"domena\" ("ilość lini")"
	exit 1
fi

if [ "$2" = "" ]
then
	ileLini=5
else
	ileLini=$2
fi

tmpfile="/tmp/rmats.analizaRuchu.${RANDOM}"
: > $tmpfile

domena=$1
serwer=$(echo $1 | ./domeny2ip.sh)

echo -n "$serwer $domena "

#sprawdzenie czy domena jest na serwerach iq
if test "$(echo $serwer | ./czyIQ.sh)" -ge "1"
then
	echo Jest na serwerze
else
	echo Nie jest u nas na serwerze.
	exit 1
fi

ssh $serwer 'for log in $(ls -tr /var/log/apacheCGI/vhost.log*); do 
	if test "${log: -3}" = ".gz"
	then
		zgrep "'$domena'" $log
	else
		grep "'$domena'" $log
	fi
done | gzip' | zcat >> $tmpfile

dni=$(cat $tmpfile | cut -d[ -f2 | cut -d: -f1 | uniq)
#echo $dni

for dzien in $dni; 
do 
	echo "----- $dzien - SUMA WEJŚĆ: $(grep $dzien $tmpfile | wc -l) -----"; 
	grep $dzien $tmpfile | cut -d" " -f2 | sort | uniq -c | sort -rn | head -n$ileLini | while read line;
	do
		echo "$line $(echo $line | awk {'print $2'} | ./ip2country.sh)"
	done
done

rm $tmpfile

