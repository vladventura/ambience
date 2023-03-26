#!/bin/sh

#get absolute path of ambience executable
#if the path is invalid, exit early
if ! realpath "./ambience"; then
    echo "error: Ambience executable not found, exitting early"
    exit
fi
#capture the output of realpath in a variable
ambiencePath=$(realpath "./ambience")
#get command line arguments
#unique identify for daemon, put as dummy argument on the end of arg list to serve as an id schema
id=$1
city=$2
hour=$3
min=$4
dow=$5

#else the path is valid and exists
#dumbs crontable into a temp file
crontab -l > crontable

#Note, xvfb MUST be installed for this to work!
#This picks a display not in use to setup a dummy display for Flutter to allow the daemons to function
xvfbComm="xvfb-run -a"
#regex to check id schema(This can be used to removed undesired ambience jobs, but rn it removes any cron job with a matching last argument)
pattern="$id\s*$"
sed -i "/$pattern/d" crontable

#testing purposes, run every minute
#append to the now new crontable
echo "$min $hour * * $dow $xvfbComm $ambiencePath $city $id" >> crontable
#remove any empty new lines, that may result from table manipulation
sed -i '/^$/d' crontable
#load modifed crontable back into cron
crontab crontable
#delete tempfile
rm crontable