#!/bin/bash

if [ $# -lt 2 ]; 
then 
	echo "$0 messageId katalog"
	exit 1
fi

mail=$1
if test "$mail" = ""
then
	exit 1
fi

katalog=$1
if test "$katalog" = ""
then
	katalog="/supertmp/smtp"
fi

testfile=/tmp/doKogo-${RANDOM}.log
: > $testfile

for i in $(ls $katalog/maillog)
do
	echo $i 1>&2
	grep $mail $i | while read line           
	do           
		czas=$(echo $line | cut -d" " -f3)
		id=$(echo $line | cut -d" " -f6)
		czasOd=$(date +%H:%M:%S -d "$(date -d "$czas") - 5 second")
		czasDo=$(date +%H:%M:%S -d "$(date -d "$czas") + 5 second")
		#echo "--------------------"
		grep $id $i | awk '$3 >= "'$czasOd'" && $3 <= "'$czasDo'"' | tr ' ' '\n' | grep 'to='
	done
done

for i in $(ls $katalog/*gz | sort -r)
do
	echo $i 1>&2
	zgrep $mail $i | while read line           
	do           
		czas=$(echo $line | cut -d" " -f3)
		id=$(echo $line | cut -d" " -f6)
		czasOd=$(date +%H:%M:%S -d "$(date -d "$czas") - 5 second")
		czasDo=$(date +%H:%M:%S -d "$(date -d "$czas") + 5 second")
		#echo "--------------------"
		zgrep $id $i | awk '$3 >= "'$czasOd'" && $3 <= "'$czasDo'"' | tr ' ' '\n' | grep 'to='
	done
done

rm $testfile
