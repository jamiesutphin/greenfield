#!/bin/bash

#Jamie jamiesutphin
#DSS build to follow Emr CF stack create

# Prerequisites
# -------------------------
# Dss license is found on an S3 bucket, configured in CF parameter
# This Bootstrap script is in the same S3 location as the CF parameter

set -x

sudo yum update -y
sudo yum install jq -y

# only run on the master node
IS_MASTER=$(curl http://169.254.169.254/latest/meta-data/security-groups | grep -i master)
echo $IS_MASTER

[[ -z $IS_MASTER ]] && exit 0

WHOAMI=$(/usr/bin/whoami)

if [ ! "$WHOAMI" == "ec2-user" ] ; then
  sudo su - ec2-user
fi

EMR_AWS_REGION=us-east-1
EMR_AWS_AZ=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
aws configure set region $EMR_AWS_REGION

TEMPJSON=/tmp/out.json

aws ec2 create-volume --size 10 --region us-east-1 --availability-zone $EMR_AWS_AZ --volume-type gp2 --tag-specifications 'ResourceType=volume,Tags=[{Key=purpose,Value=dss}]' > $TEMPJSON

sleep 5
EBS_VOL=$(jq ".VolumeId" $TEMPJSON | sed -r s/\"//g)
echo $EBS_VOL
#wait for ebs volume
sleep 35

#wait for creation
#EBS_VOL=
#if [ -z $EBS_VOL ] ; then
	EBS_VOL=$(jq ".VolumeId " $TEMPJSON | sed -r s/\"//g)
	# EBS_VOL=$(aws ec2 describe-volumes | jq ".Volumes | .[] | select(.Tags | .[] | .Value == \"dss\" ) .VolumeId" | sed -r s/\"//g)
#	sleep 15
#fi

INST=$(curl http://169.254.169.254/latest/meta-data/instance-id)
echo $INST

sleep 5
BLOCK_DEVICE=/dev/xvdf
aws ec2 attach-volume --volume-id $EBS_VOL --instance-id $INST --device $BLOCK_DEVICE

sleep 30
DATAIKU_BASE=/dataiku
DSS_DATA_DIR=/dataiku/data
sleep 5

sudo file -s $BLOCK_DEVICE
sudo mkfs -t xfs $BLOCK_DEVICE
sudo mkdir $DATAIKU_BASE
sudo mount $BLOCK_DEVICE $DATAIKU_BASE
sleep 10
sudo chown -R ec2-user $DATAIKU_BASE
mkdir -p $DSS_DATA_DIR

sleep 5

DATAIKU_VERSION=dataiku-dss-5.0.3
LICENSE_FILENAME=license-ov5kgakw.json
LICENSE_FILE_INBUCKET=s3://gbs3bucket1/$LICENSE_FILENAME
aws s3 cp $LICENSE_FILE_INBUCKET  $DATAIKU_BASE

DSS_VERS_NUMBER=5.0.3
DSS_TAR=dataiku-dss-$DSS_VERS_NUMBER.tar.gz

wget -O $DATAIKU_BASE/$DSS_TAR "https://cdn.downloads.dataiku.com/public/dss/$DSS_VERS_NUMBER/$DATAIKU_VERSION.tar.gz"
cd $DATAIKU_BASE
tar xzf $DSS_TAR

sudo -i $DATAIKU_BASE/$DATAIKU_VERSION/scripts/install/install-deps.sh -yes

$DATAIKU_VERSION/installer.sh -d $DSS_DATA_DIR -l $DATAIKU_BASE/$LICENSE_FILENAME -p 50000

$DSS_DATA_DIR/bin/dss start &
