#!/usr/bin/env bash

set -e

docker build . --tag localhost/go-ldap-admin-server

cd ./docs/docker-compose
docker-compose up -d
docker-compose stop go-ldap-admin-server
docker-compose rm go-ldap-admin-server -f
docker-compose up -d go-ldap-admin-server
cd -

docker image prune -f

docker logs -f go-ldap-admin-server
