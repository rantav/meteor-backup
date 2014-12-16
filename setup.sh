#!/bin/bash

################
# Install meteor
curl https://install.meteor.com/ | sh
# Login to meteor (if your app is on meteor.com)
meteor login
# test
meteor mongo --url my-app.meteor.com

#################################
# install node and npm, this is useful for meteor-db-utils,
# which lets you easily create cleartext backups
curl -sL https://deb.nodesource.com/setup | sudo bash -
sudo apt-get install -y nodejs
# Test npm
npm
# install meteor-db-utils
sudo npm install -g meteor-db-utils
# install mongoexport
sudo apt-get install mongodb-clients
# test
meteor-backup my-app.meteor.com users

###########################
# Install s3cmd alpha version, which support e2c instnace iam roles.
# e2c instnace iam roles is the most secure way to access S3 from an instance
# if, however you're not running on EC2 or you don't want to use e2c instnace iam roles
# then you may install any version of s3cmd and configure your ~/.s3cfg file with your credentials
sudo apt-get install python-pip
sudo pip install s3cmd==1.5.0-alpha3
# Create a dumb .s3cfg file so that the tool will use the instance iam role credentials
printf "[default]\naccess_key=\nsecret_key=\nsecurity_token=\n" > ~/.s3cfg
# Test access to your backup bucket (replace with your own bucket name)
s3cmd ls s3://my-perfect-backup/
# If you can't find s3cmd for some reason, check here: /usr/local/bin/s3cmd, e.g.
/usr/local/bin/s3cmd ls s3://my-perfect-backup/

###################################
# install mailutils so you can easily send yoursend an email when the backup runs
sudo apt-get install mailutils


# Next: set up the cron job
