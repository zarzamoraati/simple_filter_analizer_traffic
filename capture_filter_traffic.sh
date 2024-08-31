#!/bin/bash

exec 2> >(tee -a ~/review_traffic/log_errors.log)


## VARS

set -x

capture_file=~/review_traffic/capture.pcap
analize_file=~/review_traffic/filter.txt


interface=$1
interface_ops=$2
root_pass=$3


##  STEP 1  - CAPTURE INTERFACE TRAFFIC 

## chek number of args


if [[ $# -lt 3 ]]; then
	echo "Arguments given are not enough";
	exit 1;
else
	interface=$1;
	interface_ops=$2;
	printf "$root_pass" | sudo tcpdump -i "$interface"  -w "$capture_file" &
	sleep 10
	tcpdump_pid=$!
	sudo kill -2 "$tcpdump_pid"
	
	if [[ -f "$capture_file" && -s "$capture_file" ]]; then
		echo "Traffic capture succesfully¡¡¡";

	## STEP 2 - ANALIZE CAPTURE TRAFFIC
		tshark -r "$capture_file" -T fields -E header=y  -e frame.number -ip.src -e ip.dst -e http.request.method -e http.request.uri -e tcp > "$analize_file";
		if [[ -f "$analize_file" && -s "$analize_file" ]]; then 
			echo "Traffic was analize succesfully. Showing Report ....";
			echo -e "$analize_file";
		else
			echo "There was a problem trying to analize the traffic.."
			exit 1;
	fi 

	else
		echo "Any traffic could be capture";
		exit 0;
	fi
fi


