#!/bin/sh

#get absolute path of ambience executable
#if the path is invalid, exit early
if ! realpath "./ambience"; then
    echo "error: Ambience executable not found, exitting early"
    exit
fi
#get command line arguments
#unique identify for daemon, put as dummy argument on the end of cron job to serve as an id schema
idSchema=$1

#dumbs crontable into a temp file
crontab -l > crontable
#regex to remove any cron job with a matching argument on the end
pattern="$idSchema\s*$"
#remove any cron job with a matching idenity schema on the end
sed -i "/$pattern/d" crontable
#clear any empty lines left over manuplations to crontable
sed -i '/^$/d' crontable
#load modifed crontable back into cron
crontab crontable
#delete tempfile
rm crontable