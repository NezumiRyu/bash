#!/bin/bash
#Czyta albo z pliku podanego jako parametr albo z stdin;
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
katalog=$DIR/.ip2country

mkdir -p $katalog

while read ip
do
	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
	then
		if test -f $katalog/$ip
		then
			cat $katalog/$ip
		else
			country=$(whois $ip | grep -i country | rev | cut -d" " -f1 | rev | tr "\n" " ")
			echo $country | tee $katalog/$ip
		fi
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
