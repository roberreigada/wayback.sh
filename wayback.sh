#!/bin/bash

RED='\033[0;31m'
WHITE='\033[0;37m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'
orig=$(date)
epoch=$(date -d "${orig}" +"%s")
epoch_to_date=$(date -d @$epoch +%Y%m%d_%H%M%S)  

if [ $# -lt 2 ];
then
	printf "${RED}USAGE: ./wayback.sh <url> <output_file> <n_of_dates>${NC}\n"
	exit 0
fi

url=$1
outputFile=$2
ndates=$3

curl -sL https://web.archive.org/cdx/search/cdx\?url=$url\&output=json\&fl=timestamp,original\&filter=statuscode:200\&collapse=digest | grep -v "\[\[\"timestamp\",\"original\"\]," | awk -F "\"," '{print $1}' | sed 's/^..//' > tmpdates.txt
printf "\n"
if test -f "tmpdates.txt"; then
	var_dates=$(wc -l "tmpdates.txt" | awk '{print $1}')
else
	var_dates=0
	printf "${YELLOW}There are no results stored in Waybackmachine. wayback.sh completed [\xE2\x9C\x94]\n"
	printf "${NC}\n"
	exit 0
fi
printf "${YELLOW}Total dates stored in waybackmachine: ${var_dates}${GREEN}\n"
printf "\n"

if [[ "$ndates" =~ ^[0-9]+$ ]] && [[ "$ndates" -ne "0" ]]; then
	printf "${YELLOW}Dates extracted${GREEN}\n"
	printf "${RED}-----------------------------------------------------------------------${GREEN}\n"
	step=$((var_dates / ndates))
	head -1 tmpdates.txt > tmpdates2.txt
	c=1
	for date in $(cat tmpdates.txt)
	do
		let rest=$c%$step
		if [[ "$rest" -eq "0" ]]; then
			echo $date >> tmpdates2.txt
		fi
		c=$((c+1))
	done
	tail -1 tmpdates.txt >> tmpdates2.txt
	cat tmpdates2.txt | sort -u | tee tmpdates.txt
	rm -rf tmpdates2.txt
	printf "\n"
else
	printf "${YELLOW}Dates extracted${GREEN}\n"
	printf "${RED}-----------------------------------------------------------------------${GREEN}\n"
	cat tmpdates.txt
	printf "\n"
fi

if [[ $url =~ "robots.txt" ]]; then
	for date in $(cat tmpdates.txt)
	do
		printf "${YELLOW}URL: ${url} - ${date} ${i}${GREEN}\n"
		printf "${RED}-----------------------------------------------------------------------${GREEN}\n"
		curl -sL https://web.archive.org/web/${date}/${url} | tr '\r' '\n' | grep -i "allow:" | awk -F ": " '{print $2}' | sort -u | tee -a $outputFile
		printf "\n"
	done
	cat $outputFile | sort -u > tmp.txt; mv tmp.txt $outputFile
else
	mkdir $epoch_to_date
	for date in $(cat tmpdates.txt)
	do
		printf "${YELLOW}URL: ${url} - ${date} ${i}${GREEN}\n"
		printf "${RED}-----------------------------------------------------------------------${GREEN}\n"
		curl -sL https://web.archive.org/web/${date}/${url} | tr '\r' '\n' | sort -u | tee -a ${epoch_to_date}/${date}.txt
		printf "\n"
	done
	# Extract all html/php/asp/aspx/xml/js files
	cat ${epoch_to_date}/*.txt | grep -i "\.html\|\.php\|\.asp\|\.aspx\|\.xml\|\.js" | sort -u > ${epoch_to_date}/htmlphpaspxxmljsfiles
	# Extract possible parameters
	cat ${epoch_to_date}/*.txt | grep -Eo "var [a-zA-Z0-9]+" | awk -F " " '{print $2}' | sort -u > ${epoch_to_date}/parameters.txt
	mv ${epoch_to_date}/htmlphpaspxxmljsfiles ${epoch_to_date}/htmlphpaspxxmljsfiles.txt
fi
printf "\n"
printf "${YELLOW}wayback.sh completed [\xE2\x9C\x94]\n"
printf "${NC}\n"
rm -rf tmpdates.txt
exit 0
