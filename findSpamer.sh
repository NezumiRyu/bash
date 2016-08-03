#!/bin/bash

if test "$1" != ""
then
	lista="$1"
else
	lista="io europa europa2 leda pasiphae helike jokasta kallisto elara sponde carpo ananke hegemone mneme temisto kale arche ganymede carme himalia thyone dia"
fi

for i in $lista
do
	echo -e "\n---------- $i ----------"
	#czyszczenie frozenów
	ssh $i 'for id in $(chroot /home exim -bp | grep "frozen" | rev | cut -d" " -f5 | rev); do echo "$id"; chroot /home exim -Mrm $id; done' >/dev/null
	#Szukanie i wypisanie tematów wiadomości
	ssh $i 'for id in $(chroot /home exim -bp | grep "<" | rev | cut -d" " -f2 | rev | grep -v frozen); do
msg=$(chroot /home exim -Mvh $id);
master=$(echo $msg | grep "from" | cut -d" " -f2);
from=$(echo "$msg" | grep "envelope-from" | cut -d"<" -f2 | cut -d">" -f1)
docelowy=$(echo "$msg" | grep -e "To" -m1 | cut -d" " -f2-)
temat=$(echo "$msg" | grep "Subject" | cut -d" " -f3-);
echo "$id : $master : $from : $docelowy : $temat"
done' | ./mimeDecode.pl 2>/dev/null | sed 's/  */ /g' | sort -k 3

done

exit

#funkcje do analizy logów

#Usuwanie wiadomości:
#chroot /home exim -Mrm $id
function mcat { for i in $@; do echo $i >&2; if test "${i: -3}" = ".gz"; then zcat "$i"; else cat "$i"; fi; done; }


function mgrep { if test "${2: -3}" = ".gz"; then zgrep "$1" "$2"; else	grep "$1" "$2";	fi; }
function clm { if [ "$#" -ge "1" ]; then chroot /home exim -bp | grep "$1" | tr ' ' '\n' | grep -E "\w{6}\-\w{6}\-\w{2}" |xargs chroot /home exim -Mrm; fi; }
function maillog { mgrep $1 ${2:-/var/log/mail-php.log} | tail -n 20 | tr "[" " " | tr "(" " " | sed 's/  */ /g' | while read line; do echo $(echo $line | cut -d" " -f-3; echo $line | tr ' ' '\n' | grep .php; echo $line | tr ' ' '\n' | grep -A20 "To"); done | mimeDecode; }
function mailfile { mgrep $1 ${2:-/var/log/mail-php.log} | cut -d[ -f3 | cut -d: -f1 | cut -d"(" -f1 | sort | uniq | while read line; do echo "$(mgrep $line ${2:-/var/log/mail-php.log} | tail -n 1)"; done | mimeDecode; }
function follow { tail -f /var/log/mail-php.log | grep "$1"; }
function mailip { mgrep $1 ${2:-/var/log/mail-php.log} | awk {'print $6'} | sort | uniq; }
function mgrep { if test "${2: -3}" = ".gz"; then zgrep "$1" "$2"; else	grep "$1" "$2";	fi; }
function blockDocRoot { if [ "$#" -ge "1" ]; then echo -e "\nAuthType Basic\nAuthName \"Strona zablokowana przez administratora\"\nAuthUserFile $1/.htpass\nRequire valid-user" >>$1/.htaccess; chattr +i $1/.htaccess; echo -e "\niq:\$apr1\$lDAtII43\$xHjAA6cMrC6cFXeZN0tDx1" >> $1/.htpass; fi; }
function stat { echo -e "\n---------- STAT ----------\n $($(which stat) $1 | grep -ve "Birth\|Utworzenie")\n"; }
function evalFinder { nice -n 19 ionice -c2 -n7 grep -rIE "eval(\/\*.*\*\/\(|\().*\$" | sed 's/  */ /g' | sort -k2 | while read line; do echo -ne "$(echo "$line" | cut -d: -f1)\t"; echo $line | sed 's/^.*eval/eval/'; done | cut -c 1-200 | egrep --color=always "\b(eval|GLOBALS)\b|$" | less -R; }
function mimeDecode { perl -CS -MEncode -ne 'print decode("MIME-Header", $_)'; }
#wp grep wp_version wp-includes/version.php

#grep sso-bhp_www /var/log/mail-php.log | grep 90.190.85.14 | cut -d: -f1 | uniq -c

#prohost
function mgrep { if test "${2: -3}" = ".gz"; then zgrep "$1" "$2"; else	grep "$1" "$2";	fi; }
function maillog { mgrep $1 ${2:-/var/log/maillog} | tail -n 20; }
function clm { if [ "$#" -ge "1" ]; then exim -bp | grep "$1" | tr ' ' '\n' | grep -E "\w{6}\-\w{6}\-\w{2}" |xargs exim -Mrm; fi; }
function mailcat { if [ "$#" -ge "1" ]; then exim -Mvh $1; exim -Mvb $1; fi; }
function mailid { exim -bp | grep "<" | awk {'print $3'}; }
function mailq { for id in $(mailid); do msg=$(exim -Mvh $id);	master=$(echo $msg | grep "from" | cut -d" " -f2); from=$(echo "$msg" | grep "envelope-from" | cut -d"<" -f2 | cut -d">" -f1); docelowy=$(echo "$msg" | grep -e "To" -m1 | cut -d" " -f2-); temat=$(echo "$msg" | grep "Subject" | cut -d" " -f3-); echo "$id : $master : $from : $docelowy : $temat" | tr "\t" " " | sed 's/  */ /g'; done; }
function DocRoot { if [ "$#" -ge "1" ]; then grep -A10 "$1" "$(apachectl -S 2>/dev/null | grep $1 | grep "/" -m 1 | cut -d"(" -f2 | cut -d: -f1)" | grep DocumentRoot -m1 | awk {'print $2'}; fi; }
function blockDocRoot { if [ "$#" -ge "1" ]; then echo -e "\nAuthType Basic\nAuthName \"Strona zablokowana przez administratora\"\nAuthUserFile $1/.htpass\nRequire valid-user" >>$1/.htaccess; chattr +i $1/.htaccess; echo -e "\niq:\$\$lDAtII43\$xHjAA6cMrC6cFXeZN0tDx1" >> $1/.htpass; fi; }


#proste
function mgrep { if test "${2: -3}" = ".gz"; then zgrep "$1" "$2"; else	grep "$1" "$2";	fi; }
function clm { if [ "$#" -ge "1" ]; then exim -bp | grep "$1" | tr ' ' '\n' | grep -E "\w{6}\-\w{6}\-\w{2}" |xargs exim -Mrm; fi; }
function maillog { mgrep $1 /var/log/mail-php.log | tail -n 20; }
function mailfile { grep $1 /var/log/mail-php.log | cut -d[ -f3 | cut -d: -f1 | cut -d"(" -f1 | sort | uniq | while read line; do echo "$(grep $line /var/log/mail-php.log | tail -n 1)"; done; }
function follow { tail -f /var/log/mail-php.log | grep "$1"; }
function mailip { mgrep $1 ${2:-/var/log/mail-php.log} | awk {'print $6'} | sort | uniq; }

function blockDocRoot { if [ "$#" -ge "1" ]; then echo -e "\nAuthType Basic\nAuthName \"Strona zablokowana przez administratora\"\nAuthUserFile $1/.htpass\nRequire valid-user" >>$1/.htaccess; chattr +i $1/.htaccess; echo -e "\niq:\$apr1\$lDAtII43\$xHjAA6cMrC6cFXeZN0tDx1" >> $1/.htpass; fi; }

mail.proste.pl:




