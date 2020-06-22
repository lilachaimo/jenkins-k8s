#!/bin/bash



echo maven-project > /tmp/.auth
echo $BUILD_TAG >> /tmp/.auth
echo $PASS >> /tmp/.auth

scp -i /opt/prod /tmp/.auth  prod-user2@192.168.1.241:/tmp/.auth
scp -i /opt/prod ./jenkins/deploy/publish prod-user2@192.168.1.241:/tmp/publish
ssh -i /opt/prod  prod-user2@192.168.1.241 "/tmp/publish"
