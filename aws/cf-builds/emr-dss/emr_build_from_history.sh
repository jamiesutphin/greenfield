# Prerequisites
# -------------------------
# Dss license is found on an S3 bucket, configured
# in Cloudformation parameter

EMR_AWS_AZ=us-east-1c

sudo su - ec2-user

aws configure set region us-east-1

aws ec2 create-volume --size 32 --region us-east-1 --availability-zone $EMR_AWS_AZ --volume-type gp2 --tag-specifications 'ResourceType=volume,Tags=[{Key=purpose,Value=dss}]'


EBS_VOL=$(aws ec2 describe-volumes | jq ".Volumes | .[] | select(.Tags | .[] | .Value == \"dss\" ) .VolumeId" | sed -r s/\"//g)

INST=$(curl http://169.254.169.254/latest/meta-data/instance-id)
echo $INST


aws ec2 attach-volume --volume-id $EBS_VOL --instance-id $INST --device /dev/sdf

lsblk
aws ec2 describe-volumes
lsblk

DATAIKU_BASE=/dataiku
BLOCK_DEVICE=/dev/xvdf
DSS_DATA_DIR=/dataiku/data
sudo file -s $BLOCK_DEVICE
sudo mkfs -t xfs $BLOCK_DEVICE
sudo mkdir $DATAIKU_BASE
sudo mount $BLOCK_DEVICE $DATAIKU_BASE
sudo chown -R ec2-user $DATAIKU_BASE
mkdir $DSS_DATA_DIR



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
