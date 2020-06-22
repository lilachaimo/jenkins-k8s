#!/bin/bash




echo "******************************"
echo "********** Pushing image *****"
echo "******************************"

IMAGE="maven-project"


echo "******** Logging in **********"
docker login -u lilachyonash -p $PASS
echo "******* Tagging image ********"
docker tag $IMAGE:$BUILD_TAG lilachyonash/$IMAGE:$BUILD_TAG
echo "****** Pushing image *********"
docker push lilachyonash/$IMAGE:$BUILD_TAG 
