#!/bin/sh

echo "region          instance                tag             priv.IP         pub.IP    status"
aws ec2 describe-instances --output text \
--query "Reservations[*].Instances[*].{Instance:InstanceId,\
  Name:Tags[?Key=='name']|[0].Value,AZ:Placement.AvailabilityZone,\
  PrivateIpAddresses:PrivateIpAddress, PublicIpAddresses:PublicIpAddress,\
  State:State.Name}" \
--region=eu-central-1;
aws ec2 describe-instances --output text \
--query "Reservations[*].Instances[*].{Instance:InstanceId,\
  Name:Tags[?Key=='name']|[0].Value,AZ:Placement.AvailabilityZone,\
  PrivateIpAddresses:PrivateIpAddress, PublicIpAddresses:PublicIpAddress,\
  State:State.Name}" \
--region=us-east-1

echo aws ec2 start-instances --region … --instance-ids i-… i-…
