#!/bin/sh

#get absolute path of ambience executable
#if the path is invalid, exit early
if ! realpath "./ambience"; then
    echo "error:file doesn't exist"
    exit
fi
#else the path is valid and exists
#capture the output of #!/bin/sh
#dumbs crontable into a temp file
crontab -l > crontable

#get absolute path of ambience executable
#if the path is invalid, exit early
if ! realpath "./ambience"; then
    echo "error:file doesn't exist"
    exit
fi
#else the path is valid and exists

#capture the output of realpath in a variable
ambiencePath=$(realpath "./ambience") 
#gets city target from the commandline
ambienceInputCity=$1
#Note, xvfb MUST be installed for this to work!
#This picks a display not in use to setup a dummy display for Flutter
xvfbComm="xvfb-run -a"

#regex to match the time parameters of cron
cpr="(([0-9]+\s)|(\*\s)){5})"

#regex used to check for old ambience jobs
ambienceJobCheck=" $cpr $xvfbComm $ambiencePath \w+"
#Copy all over all non-ambience jobs, this basically deletes old ambience cron jobs.
newCrontable=$(crontable | grep -e "$ambienceJobCheck")
#overwrite contrable with the new one
echo "$newCrontable" > crontable
#testing purposes, run every minute
#append to the now new crontable
echo "* * * * * $xvfbComm $ambiencePath $ambienceInputCity" >> crontable
#remove any empty new lines
sed -i '/^$/d' crontable
#load modifed crontable back into cron
crontab crontable
#delete tempfile
rm crontable