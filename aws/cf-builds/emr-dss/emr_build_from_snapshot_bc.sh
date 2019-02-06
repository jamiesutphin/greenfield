#!/bin/bash

#Jamie jamiesutphin
#DSS build to follow Emr CF stack create

# Prerequisites
# -------------------------
# Dss license is found on an S3 bucket, configured in CF parameter
# A valid snapshot of Dataiku must be found in Snapshots

set -x
sudo yum update -y
sudo yum install jq -y

# only run on the master node
IS_MASTER=$(curl http://169.254.169.254/latest/meta-data/security-groups | grep -i master)
echo $IS_MASTER



[[ -z $IS_MASTER ]] && exit 0
EMR_AWS_REGION=us-east-1
EMR_AWS_AZ=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
aws configure set region $EMR_AWS_REGION

/usr/bin/whoami

#Tag the Master Instance Cname
#Only Named Instance Tags get AutoSnapshots via Lambda
INST=$(curl http://169.254.169.254/latest/meta-data/instance-id)
echo $INST
aws ec2 create-tags --resources $INSTID --tags Key=Name,Value="Dna Dss MasterNode"

TEMPJSON=/tmp/out.json
# Get latest Backup snapshot
LATEST_SNAP=$(aws ec2 describe-snapshots --filters Name=tag:Name,Values="autosnap-Dna Dss MasterNode*" | jq " .[] | max_by(.StartTime) | .SnapshotId" | sed -r s/\"//g | sed -r s/null//g)
[[ -z $LATEST_SNAP]] && echo "FATAL Error: No snapshot to restore." && exit 1
aws ec2 create-volume --size 10 --snapshot-id $LATEST_SNAP  --region us-east-1 --availability-zone $EMR_AWS_AZ --volume-type gp2 --tag-specifications 'ResourceType=volume,Tags=[{Key=purpose,Value=DNA-dss-emrmaster}]' > $TEMPJSON

sleep 5
EBS_VOL=$(jq ".VolumeId" $TEMPJSON | sed -r s/\"//g)
echo $EBS_VOL
#wait for ebs volume
sleep 35

EBS_VOL=$(jq ".VolumeId " $TEMPJSON | sed -r s/\"//g)

sleep 5

# Limit attempts to two block devices, if this is
# cause for error (unlikely), then expand this code
# to try more devices
BLOCK_DEVICE=/dev/xvdf
IS_DEVICE_IN_SERVICE=$(lsblk $BLOCK_DEVICE | grep -c "not a block device" )
if [ $IS_DEVICE_IN_SERVICE -eq 0 ]; then
   aws ec2 attach-volume --volume-id $EBS_VOL --instance-id $INST --device $BLOCK_DEVICE
else
  BLOCK_DEVICE=/dev/xvdm
  IS_DEVICE_IN_SERVICE=$(lsblk $BLOCK_DEVICE | grep -c "not a block device" )
  [[ $IS_DEVICE_IN_SERVICE -eq 0 ]] && echo "FATAL error: Both mountpoints used." && exit 1
  aws ec2 attach-volume --volume-id $EBS_VOL --instance-id $INST --device $BLOCK_DEVICE

fi

sleep 30
DATAIKU_BASE=/dataiku
DSS_DATA_DIR=/dataiku/data
sleep 5

#sudo file -s $BLOCK_DEVICE
#sudo mkfs -t xfs $BLOCK_DEVICE
sudo mkdir $DATAIKU_BASE
sudo mount $BLOCK_DEVICE $DATAIKU_BASE
sleep 10

# for this build, temporarily make ec2-user the owner
# as this user runs the code
sudo chown -R ec2-user $DATAIKU_BASE
mkdir -p $DSS_DATA_DIR

sleep 5

# If no backup Snap was found,
# this is a new installation
if [ -z $LATEST_SNAP ]; then

  DATAIKU_VERSION=dataiku-dss-5.0.3
  LICENSE_FILENAME=license-bc-trial-0228.json
  LICENSE_FILE_INBUCKET=s3://dna-wma-dss/cf-build/$LICENSE_FILENAME
  aws s3 cp $LICENSE_FILE_INBUCKET  $DATAIKU_BASE

  DSS_VERS_NUMBER=5.0.3
  DSS_TAR=dataiku-dss-$DSS_VERS_NUMBER.tar.gz

  wget -O $DATAIKU_BASE/$DSS_TAR "https://cdn.downloads.dataiku.com/public/dss/$DSS_VERS_NUMBER/$DATAIKU_VERSION.tar.gz"
  cd $DATAIKU_BASE
  tar xzf $DSS_TAR

  # cleanup tarfile after extraction
  [[ -d $DATAIKU_BASE/$DATAIKU_VERSION ]] && rm $DATAIKU_BASE/$DSS_TAR

  sudo -i $DATAIKU_BASE/$DATAIKU_VERSION/scripts/install/install-deps.sh -yes
  sudo -i $DATAIKU_BASE/$DATAIKU_VERSION/scripts/install/install-deps.sh -yes -without-java -without-python -with-r

  $DATAIKU_VERSION/installer.sh -d $DSS_DATA_DIR -l $DATAIKU_BASE/$LICENSE_FILENAME -p 50000

  # install Spark integration
  $DSS_DATA_DIR/bin/dssadmin install-spark-integration
  $DSS_DATA_DIR/bin/dssadmin install-R-integration

  cd ~
  sudo chown -R hadoop:hadoop $DATAIKU_BASE

fi

sudo su - hadoop -c "$DSS_DATA_DIR/bin/dss start "

exit 0
