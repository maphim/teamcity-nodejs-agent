#!/bin/sh

NAME=snatalenko/teamcity-nodejs-agent
VERSION=2017.1.5

docker build -t $NAME:latest .

echo ""
read -p "Release version $VERSION ? [y/N] " yn
echo ""

if [[ "$yn" = "y" ]]; then
	docker tag $NAME:latest $NAME:$VERSION
	docker push $NAME:latest
	docker push $NAME:$VERSION
fi
