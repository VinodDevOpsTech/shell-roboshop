#!/bin/bash
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z0584760TQ3FQFBERSRB"
DOMAIN_NAME="maxdevopstech.online"

for instance in $@
do
    echo "launching instance: $instance"
    INSTANCE_ID=$(aws ec2 run-instances \
    --instance-ids $AMI_ID \
    --instance-type t3.micro \
    --security-group "roboshop-common" "roboshop-$instance" \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Test}]' \
    --query 'Instances[0].InstanceId' \
    --output text
    )
    echo "instance id:$INSTANCE_ID"


    if [ $instance == "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-id i-1234567890abcdef0 \
        --query "Reservations[*].Instances[*].PublicIpAddress" \
        --output text
        )
        R53_RECORD="$DOMAIN_NAME"

    else
        IP=$(aws ec2 describe-instances --instance-id i-1234567890abcdef0 \
        --query "Reservations[*].Instances[*].PublicIpAddress" \
        --output text
        )
        R53_RECORD="$instance.$DOMAIN_NAME"
    fi
done
    