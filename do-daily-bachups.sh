#!/bin/bash 

# This automated backup script is designed for use with the DashingWP file system.
# Author: Jesse Lawson

# Get the file of our clients
# load the list_of_clients file into an array to work with
declare -a clients
readarray -t clients < list_of_clients # Exclude newline.

# Please note that I have a list of clients stored in a file called "list_of_clients". Obviously you could create your own 
# variable full of client names, as the script loops through each of them (one name on each newline). 

# Loop through each client on our list

# Loop through all clients read from array
for i in "${clients[@]}"
do
	# Set some variables for this site backup

	# Our backup schema: 
	# 	ex: yoursite.daily_1.tar is a backup on the 1st of whatever month it is
	#	ex: yoursite.daily_15.tar is a backup on the 15th of whatever month it is
	# 	When displaying backups, we can use timestamps to sort them, or just know that whatever day of the month it currently
	# 	is will render all higher day values as part of last month. 
	NOW=$(date +"%d")
	FILE="$i.daily_$NOW.zip"

	BACKUP_DIR="/var/www-backups/$i"
	
	WWW_DIR="/var/www/$i.yoursite.com/"

	# Navigate to folder and backup database to a file in wp-content
	cd /var/www/$i.yoursite.com

	# Backup database to wp-content folder
	
		# Extract db variables from config file
	
		DB_NAME=`cat wp-config.php | grep DB_NAME | cut -d \' -f 4`
		DB_USER=`cat wp-config.php | grep DB_USER | cut -d \' -f 4`
		DB_PASS=`cat wp-config.php | grep DB_PASSWORD | cut -d \' -f 4`
		DB_FILE="mysql.sql"

		echo -e "BEGIN BACKUP FOR $i..."
		echo -e "DB_USER=$DB_USER"
		echo -e "DB_PASS=$DB_PASS"
		echo -e "DB_NAME=$DB_NAME"

		# mkdir if it doesn't exist. It's only temporary
		mkdir -p $BACKUP_DIR
		
		# Dumb database to mysql.sql in wp-content folder
		mysqldump -u$DB_USER -p$DB_PASS $DB_NAME > "${WWW_DIR}htdocs/wp-content/${DB_FILE}"

	# Copy over the wp-config.php file so that we can just zip the htdocs folder
		cp wp-config.php htdocs/wp-config.php

	# zip wp-content backup

		echo -e "Zipping the backup...\n"

		# Go into htdocs so the zip goes straight to the directory
		cd htdocs

		# specifically exclude wp-snapshots because SOMEONE keeps using that plugin

		zip -9 -r --exclude=*wp-snapshots* $BACKUP_DIR/$FILE .

		# Note here we're zipping the contents of htdocs to omit the log folder
		
	# Push to S3 
	
		echo -e "Pushing to S3...\n"
		s3cmd put $BACKUP_DIR/$FILE s3://yoursite/snapshots/$i/$FILE

	
	# Remove backup dir and wp-content from htdocs (see daily work journal, 9 Jan 2014)
	
		rm -rfv $BACKUP_DIR
		rm -rfv /var/www/$i.yoursite.com/htdocs/wp-config.php
		
		echo -e "Done!\n"



		# Write to backup log file
		TIMESTAMP=$(date + "%s")
		echo "Daily #$NOW backup for $i completed at $TIMESTAMP\n" >> /var/www-backups/log/daily-backups.log
		
done
