aws --version
aws configure -set region us-east-1
aws configure set region us-east-1
aws s3 ls
lsblk
aws ec2 create-volume --size 32 --region us-east-1 --availability-zone us-east-1a --volume-type gp2 --tag-specifications 'ResourceType=volume,Tags=[{Key=purpose,Value=dss}]'
aws ec2 list-volumes | head
aws ec2 describe-volumes
aws ec2 describe-volumes | head
aws ec2 describe-volumes | jq ".Volumes | .[] | .Tags"
aws ec2 describe-volumes | jq ".Volumes | .[] | select(.Tags.Value==\"dss\") "
aws ec2 describe-volumes | jq ".Volumes | .[] | select(.Tags.Value == \"dss\") "
aws ec2 describe-volumes | jq ".Volumes | .[] | .Tags"
aws ec2 describe-volumes | jq ".Volumes | .[] | .Tags.Value"
aws ec2 describe-volumes | jq ".Volumes | .[] | .Tags | .[] "
aws ec2 describe-volumes | jq ".Volumes | .[] | .Tags | .[] | Value"
aws ec2 describe-volumes | jq ".Volumes | .[] | .Tags | .[] | .Value"
aws ec2 describe-volumes | jq ".Volumes | .[] | select(.Tags | .[] | .Value == \"dss\" "
aws ec2 describe-volumes | jq ".Volumes | .[] | select(.Tags | .[] | .Value == \"dss\" ) "
aws ec2 describe-volumes | jq ".Volumes | .[] | select(.Tags | .[] | .Value == \"dss\" ) .VolumeId"
EBS_VOL=$(aws ec2 describe-volumes | jq ".Volumes | .[] | select(.Tags | .[] | .Value == \"dss\" ) .VolumeId")
echo $EBS_VOL 
curl http://169.254.169.254/latest/meta-data/
curl http://169.254.169.254/latest/meta-data/instance-id
INST
INST=$(curl http://169.254.169.254/latest/meta-data/instance-id)
echo $INST
aws ec2 attach-volume --volume-id $EBS_VOL --instance-id $INST --device /dev/sdf
echo $EBS_VOL 
echo $EBS_VOL | tr '"' ''
echo $EBS_VOL | tr '"' ' '
echo $EBS_VOL | sed -r s/"//g
echo $EBS_VOL | sed -r s/\"//g
EBS_VOL_NOQUOTES=$($EBS_VOL | sed -r s/\"//g)
EBS_VOL_NOQUOTES=$(echo $EBS_VOL | sed -r s/\"//g)
echo $EBS_VOL_NOQUOTES 
aws ec2 attach-volume --volume-id $EBS_VOL_NOQUOTES --instance-id $INST --device /dev/sdf
curl http://169.254.169.254/latest/meta-data/
curl http://169.254.169.254/latest/meta-data/network
curl http://169.254.169.254/latest/meta-data/network/placement
curl http://169.254.169.254/latest/meta-data/placement
curl http://169.254.169.254/latest/meta-data/
curl http://169.254.169.254/latest/meta-data/metrics
history | grep create
history 6
aws ec2 create-volume --size 32 --region us-east-1 --availability-zone us-east-1c --volume-type gp2 --tag-specifications 'ResourceType=volume,Tags=[{Key=purpose,Value=dss}]'
aws ec2 delete-volume help
aws ec2 delete-volume --volume-id $EBS_VOL_NOQUOTES 
history |grep jq
EBS_VOL=$(aws ec2 describe-volumes | jq ".Volumes | .[] | select(.Tags | .[] | .Value == \"dss\" ) .VolumeId")
history | grep sed
EBS_VOL_NOQUOTES=$(echo $EBS_VOL | sed -r s/\"//g)
history | grep attach
aws ec2 attach-volume --volume-id $EBS_VOL_NOQUOTES --instance-id $INST 
aws ec2 attach-volume --volume-id $EBS_VOL_NOQUOTES --instance-id $INST --device /dev/sdf
lsblk
aws ec2 describe-volumes
lsblk
file -s /dev/xvdf
sudo file -s /dev/xvdf
sudo mkfs -t xfs /dev/xvdf
sudo mkdir /dataiku
sudo mount /dev/xvdf /dataiku
sudo chown -R ec2-user /dataiku
mkdir /dataiku/data
history -w emr_build.txt
