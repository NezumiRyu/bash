#!/bin/bash
#Czyta albo z pliku podanego jako parametr albo z stdin;
# Jeżeli 2 param to d to dopisuje kraj
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
katalog=$DIR/.ip2country

mkdir -p $katalog

while read line
do
	ip=$(echo $line | tr " " "\n" | grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$")
	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
	then
		if test ! -f $katalog/$ip
		then
			country=$(whois $ip | grep -i country | rev | cut -d" " -f1 | rev | tr "\n" " ")
			echo $country > $katalog/$ip
		fi

		if test "$2" = "-d"
		then
			echo -n "$line : "
		fi
		cat $katalog/$ip
	fi
done < "${1:-/dev/stdin}"

exit

while read ip
do
	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
	then
		echo "$(whois $ip | grep -i country | rev | cut -d" " -f1 | rev | tr "\n" " ")"
	fi
done < "${1:-/dev/stdin}"
