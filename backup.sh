#!/bin/bash
SITE=my-app.meteor.com

###############################################################
# Get the directory the script is being run from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $DIR
# Store the current date in YYYY-mm-DD-HHMMSS
DATE=$(date -u "+%F-%H%M%S")
FILE_NAME="backup-$DATE"
ARCHIVE_NAME="$FILE_NAME.tar.gz"

########################################################
# dump as json files
# List your connections here
COLLECTIONS="emails users teams companies employees migrations roles"
meteor-backup $SITE $COLLECTIONS -d $DIR/backup/$FILE_NAME

####################################################################
# dump as binary file
TEMPFILE=$DIR/URL.tmp
meteor mongo --url $SITE | tee $TEMPFILE

if [ $PIPESTATUS -ne 0 ] ; then
  echo "Could not connect to your app's server."
  exit 1
fi

MONGO_SERVER_URL=$(tail -n 1 $TEMPFILE)
rm $TEMPFILE

# regex works (tested) for what meteor.com returns for 0.7.0
# sample server url:mongodb://client:THIS-IS-PASSWORD@MONGO-SERVER-URL/DATABASE-URL
# for python version of similar tool: http://pydanny.com/parsing-mongodb-uri.html
MONGODUMP_ARGUMENTS=$(echo $MONGO_SERVER_URL | sed "s|mongodb://\([a-zA-Z0-9-]*\):\([a-zA-Z0-9-]*\)@\([a-zA-Z0-9\:.-]*\)/\(.*\)|--username \1 --password \2 --host \3 --db \4|")

if [ $? -ne 0 ] ; then
  echo "Failed to parse mongodump results, please take a look at this script (it may be outdated)"
  exit 1
fi

rm -r $TEMP_DUMP_LOCATION
mongodump $MONGODUMP_ARGUMENTS --out $DIR/backup/$FILE_NAME/mongodump




##############################################################
# Tar Gzip the file
tar -C $DIR/backup/ -zcvf $DIR/backup/$ARCHIVE_NAME $FILE_NAME/

##########################################
# Remove the backup directory
rm -r $DIR/backup/$FILE_NAME

############################################################
# Send the file to the backup drive or S3
/usr/local/bin/s3cmd put $DIR/backup/$ARCHIVE_NAME s3://my-perfect-backup/

######################################################
# delete files older than 7 days
find $DIR/backup -mtime +7 -exec rm {} \;

echo "DONE"