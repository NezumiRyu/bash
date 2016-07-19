#!/bin/bash
#Czyta albo z pliku podanego jako parametr albo z stdin;
while read line
do
	#echo "$line"
	if [[ $line =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
	then
		host $line | grep -ci iq.pl
	fi		

done < "${1:-/dev/stdin}"
