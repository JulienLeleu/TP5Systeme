#!/bin/bash

PATH=$(cd $(dirname $0) ; pwd):$PATH

tube=/tmp/requete
mkfifo $tube 2> /dev/null

while true
do
	cat $tube | ./process-request.sh | nc -p 8080 -l > $tube
done