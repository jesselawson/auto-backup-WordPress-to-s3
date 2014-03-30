Auto backup WordPress to S3
===========================

A bash script that automatically creates a backup of WordPress (DB+Files) and pushes a timestamped zip file into the Amazon S3 cloud. Just add cron!

**Please note** that this is built around the Nginx filesystem -- specifically, the Easy Engine filesystem. That being said, this will pretty much work with any type of filesystem schema as long as you pay attention to each line and change what is needed.

*Please modify this script before you use it!* This is not a plug-and-play script; you need to modify it to suit your filesystem schema and requirements.

# Installation

1. Put the `do-daily-backups.sh` file into some directory on your server, something like `/var/tools`
2. In terminal, edit your cron jobs with `crontab -e` and add a line to call this script once every morning around 1-3AM (sometime when you have the least amount of traffic). 
3. Profit.
