#!/usr/bin/sudo bash

# instalation of  geoip tool
function geo(){
echo " Please wait, installing script's dependencies"
echo "                                              "
sleep 2
sudo apt install geoip-bin -y 
clear
}
geo

#start ftp server

sudo service vsftpd start

# Live capture mode
function honeypot_monitor() {
echo "                                                                "
echo " honeypot is running, to stop capturing press [ ENTER ] "
echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
sleep 4
tail -f /var/log/auth.log & tail_pid=$!  
read _                                   
kill "$tail_pid"                        
}



# pre parsing process message
function extrip() {
 
echo "                           "
echo " Parsing the auth.log file"
sleep 5 &
PID=$!
i=1
sp="/-\|"
echo -n ' '
while [ -d /proc/$PID ]
do
  printf "\b${sp:i++%${#sp}:1}"
done
clear
}


# extracting the suspicious ip and either block it via iptables or analyze it.
# If port 21 was changed, change the in the  |grep 21| command
function parsing() {
netstat -antp > conn.txt
intruderip=$(sudo cat conn.txt | grep 21 | awk '{print $5}' | grep -v "*" | cut -d ':' -f1)
echo "                           "
echo "-  - - - - - - - - - - - - - - - -"
echo " The suspicious IP is:  "
echo $intruderip
echo "- - - - - - - - - - - - - - - - - "
echo "                                                "
echo "                                    "
echo " Do you wish to block that IP? "
echo " [ 1 ] Block and analyze (works only on attacks performed not from this device)"
echo " [ 2 ] Do not block only anlyze (can take a while)"
read var
if [ $var -eq 1 ] 
then
	sudo iptables -I INPUT -s $intruderip -j DROP 
	echo " Investigating" $intruderip
	echo "                           "
	nmap -Pn -p- -A -T4 $intruderip 
	geoiplookup $intruderip 
	
elif [ $var -eq 2 ]
then
	echo " Investigating" $intruderip
	echo "                           "
	nmap -Pn -p- -A -T4 $intruderip 
	geoiplookup $intruderip 
	

fi
}


honeypot_monitor
extrip
parsing






