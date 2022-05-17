#!/bin/bash

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
export PATH

cd /docker-data/i40sys

cd crawler
date 2>&1 | tee crontab_crawler.log 
echo -n "[] crawler job... "
docker-compose up >> crontab_crawler.log 2>&1
docker-compose down >> crontab_crawler.log 2>&1
echo "DONE"
date 2>&1 | tee -a crontab_crawler.log 

cd ../get_slugs
date 2>&1 | tee crontab_get_slugs.log
echo -n "[] crawler job... "
docker-compose run --rm get_slugs > crontab_get_slugs.log 2>&1
echo "DONE"
date 2>&1 | tee -a crontab_get_slugs.log

cd ..
DP=$(docker-compose ps|cut -f 1 -d " "|tail -n 1)
PID=$(docker inspect ${DP}|jq '.[].State.Pid')
kill -HUP $PID

