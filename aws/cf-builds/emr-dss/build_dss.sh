#!/bin/bash
#Jamie Sutphin, WebbMason Analytics
#Created 1/24/19

#After Aws EMR creation, during bootstrap install Dataiku on
#the master node only.

#query the User Data metadata to find master node
IS_MASTER=$(curl ...)
LOGFILE='/tmp/boot-dss.log'

if [ $IS_MASTER = "" ]; then
  echo "Found master node... contiue" > $LOGFILE
else
  echo "Is not master node. Exit" > $LOGFILE
  exit 0
fi

sudo aws ec2 create-volume --size 32 --region us-east-1 --availability-zone us-east-1b --volume-type gp2

#to do
#get VolumeName
BLOCK_DEVICE=$()

# Filesystem check - should be block device
NO_FILESYSTEM = $(sudo file -s $BLOCK_DEVICE)
if [ $NO_FILESYSTEM = ""]; then
  echo "Format and mount device" >>$LOGFILE
else
  echo "Cannot format, filesystem is found. Exit" >> $LOGFILE
  exit 1
fi

sudo mkfs -t ext4 $BLOCK_DEVICE

#to do

#Create dataiku directory on secondary ebs volume
sudo mkdir "/mnt/dataiku"
sudo chown -R hadoop: "/mnt/dataiku"
#Load DSS license
aws s3 cp "s3://wma13-emr/Cloudformation/License.json" "/mnt/dataiku/license.json"
#Install Dss Automation
wget -O "/mnt/dataiku/dataiku-dss-5.0.3.tar.gz" "https://cdn.downloads.dataiku.com/public/dss/5.0.3/dataiku-dss-5.0.3.tar.gz"
sudo tar xzf "/mnt/dataiku/dataiku-dss-5.0.3.tar.gz" -C "/mnt/dataiku"
sudo -i "/mnt/dataiku/dataiku-dss-5.0.3/scripts/install/install-deps.sh" -without-java -yes
sudo -u hadoop /mnt/dataiku/dataiku-dss-5.0.3/installer.sh -t automation -d "/mnt/dataiku/dss" -p 12000 -l "/mnt/dataiku/license.json"
#Install mysql JDBC driver
wget -O "/mnt/dataiku/dss/lib/jdbc/mysql-connector-java-8.0.13.tar.gz" "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.13.tar.gz"
sudo tar -xvf "/mnt/dataiku/dss/lib/jdbc/mysql-connector-java-8.0.13.tar.gz" -C "/mnt/dataiku/dss/lib/jdbc"
sudo mv "/mnt/dataiku/dss/lib/jdbc/mysql-connector-java-8.0.13/*" "/mnt/dataiku/dss/lib/jdbc"
#Install Spark integration
/mnt/dataiku/dss/bin/dssadmin install-spark-integration
#Start DSS
/mnt/dataiku/dss/bin/dss start
