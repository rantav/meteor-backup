# meteor-backup

Backup script for meteor mongodb

This is a mix of several backup utilities collected from the community and packaged for easy deployment on EC2 (or other).

This script can easily download the contents of your meteor database and upload it to S3.
It is designed to work well with hosting on meteor.com as well as private meteor deployments.
And with a one small adjustments it is easy to make it work for generic mongo databases backups, not just meteor specific.

## Setup:
Set up a host to run the backup. In this example we show how to set up a micro EC2 host that'll run the nightly backups but of cousrse you may use any other hosting service or even your own laptop or PC.

### AWS setup
1. Create an S3 bucket for the backup, eg `my-perfect-backup`
2. For increased security we're using an [instance IAM role](http://aws.amazon.com/about-aws/whats-new/2012/06/11/Announcing-IAM-Roles-for-EC2-instances/), which lets us get away from storing actual AWS credentials on the host itself. AWS will take care of providing short lived one-time credentials to the `s3cmd` tool when it needs them. Create a role named **MeteorMongoBackup**. The *Role Type* should be *Amazon EC2*, next click on *Custom Policy* and insert the contents of the file `MeteorMongoBackupRole.json` (replacing `my-perfect-backup` with your own bucket name from step 0) 
3. Boot up an EC2 micro instance (a micro should be enough). When you create this instance make sure you select `MeteorMongoBackup` as the instance role. This will allow the host to seamlessly access your S3 bucket without needing to hardcode your AWS credentials on it. 

### Backup host setup
1. Once the host is running, ssh to this host and run the `setup.sh` script. Note that this script contains many sections (some of them are optional) so my suggestion is that you read it and run each line manually. 
2. Edit the file `backup.sh` to update the `SITE` URL and the `COLLECTIONS`. The `COLLECTIONS` is only needed if you want to crate cleartext (json) backups using the `meteor-backup` tool. If you're only interested in binary backups (bson) using `mongodump` then no need to specify the collections, they will all be backed up automatically, in binary format. json backups are useful for diffing or looking at just one collection's data, or grepping through them, but they also consume some more space. 
3. Next, test the `backup.sh` script by running `/bin/bash backup.sh`
4. Set up a cron job by running `crontab -e` and adding the contents of the `crontab` file from this repository

### Troubleshooting
If you're having troubles try following these steps:  
1. Run `backup.sh` outside of cron and check if it's successful. You should see `DONE` at the end and no errors in betweem. 
2. If cron gives you hard time you can try to debug it by first running it every minute and then inspecting syslog when it runs. To run every minute use the following cron string `* * * * *` (instead of `0 0 * * *`). Now tail syslog and wait for cron to run: `tail -f /var/log/syslog`. Don't forget to update the cron string when you're done such that it won't run every minute forever...

### Variations
This simple setup is useful to backup meteor.com installation.  
In case you'd like to backup other mongo installationas you might need just a subset of these, for example you will likely have the username/password provided, rather than having to run `meteor mongo --url` and `sed` to get the credentials. 

