#!/bin/bash

STACK=`aws cloudformation describe-stacks --stack-name VscodeOnEc2ForPrototypingStack`
INSTANCE_ID=`echo $STACK | jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "InstanceID") | .OutputValue'`
PRIVATE_IP=`echo $STACK | jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "PrivateIP") | .OutputValue'`

echo 'Instance ID='.$INSTANCE_ID
echo 'Private IP='.$PRIVATE_IP

aws ssm start-session \
    --target $INSTANCE_ID \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters "{\"portNumber\":[\"8080\"],\"localPortNumber\":[\"8080\"],\"host\":[\"${PRIVATE_IP}\"]}"
