#!/bin/bash

rm -f /home/apollo/rpt/usr_file
touch /home/apollo/rpt/usr_file
getent passwd | egrep -v '/s?bin/(nologin|shutdown|sync|halt)' | cut -d: -f1 >> /home/apollo/rpt/usr_file

rm -f /home/apollo/rpt/log.txt
touch /home/apollo/rpt/log.txt
echo "Log of command line history of each CentOS user" >> /home/apollo/rpt/log.txt
now=$(date +"%m_%d_%Y")
echo "Report generated on - $now" >> /home/apollo/rpt/log.txt
echo $'\n' >> /home/apollo/rpt/log.txt

usr_array=$'\n' array=($(cat /home/apollo/rpt/usr_file))

for i in "${array[@]}"
do
	echo "############### History of user $i ###############" >> /home/apollo/rpt/log.txt
	sudo cat /home/$i/.bash_history | grep 'wget\|sudo\|rm\|make\|configure\|update\|curl\|export' >> /home/apollo/rpt/log.txt
	echo "##################################################" >> /home/apollo/rpt/log.txt
	echo $'\n' >> /home/apollo/rpt/log.txt
done

rm -f /home/apollo/rpt/changes.txt
touch /home/apollo/rpt/changes.txt
echo "These files have been modified in the last 24 hours on the server" >> /home/apollo/rpt/changes.txt
echo $'\n' >> /home/apollo/rpt/changes.txt
sudo find /home/ -mtime -7 -ls | grep -v cache >> /home/apollo/rpt/changes.txt

rm -f /home/apollo/rpt/weekly_summary.txt
touch /home/apollo/rpt/weekly_summary.txt
echo "The overall summary of server actions in the last week." >> /home/apollo/rpt/weekly_summary.txt
echo $'\n' >> /home/apollo/rpt/weekly_summary.txt
aureport -ts week-ago -te now --summary -i >> /home/apollo/rpt/weekly_summary.txt

mv /home/apollo/rpt/log.txt /home/apollo/rpt/commands_executed.txt
mv /home/apollo/rpt/changes.txt /home/apollo/rpt/files_modified.txt

/bin/mail -s "Server log of $now" -a /home/apollo/rpt/commands_executed.txt -a /home/apollo/rpt/files_modified.txt -a weekly_summary.txt -b hsing247@uwo.ca mnajafi7@uwo.ca < /home/apollo/rpt/message.txt
rm -f /home/apollo/rpt/usr_file
rm -f /home/apollo/rpt/commands_executed.txt
rm -f /home/apollo/rpt/files_modified.txt
rm -f /home/apollo/rpt/weekly_summary.txt

sudo yum update -y


