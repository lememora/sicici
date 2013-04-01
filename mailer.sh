#!/bin/bash

if [ "$1" != "start" ]
then
  echo "usage: nohup ./mailer.sh start > mailer.out 2> mailer.err < /dev/null &"
  exit
fi

basedir="$(echo $0 | sed s/"\/mailer.sh"//g)"
method="exit"

function run
{
  curdate=$(date +%y%m%d)
  /usr/bin/ruby $basedir/script/runner "MailerDaemon.campaign_job_starter ; sleep 5 ; MailerDaemon.campaign_job_finalizer ; sleep 5 ; MailerDaemon.campaign_dispatcher ; sleep 5 ; MailerDaemon.campaign_dsn_parser ; sleep 5 ; MailerDaemon.campaign_schedule_observer ; sleep 5 ; MailerDaemon.campaign_job_gc ; sleep 5" >> "$basedir/log/mailer.$curdate.log"
}

while [ true ]
do
  run
  sleep 15s
done
