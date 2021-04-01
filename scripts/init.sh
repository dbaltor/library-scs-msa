#!/bin/bash
set -e
cd $(dirname $0)

# Creating required service instances
cf create-service p.mysql db-small library-ms
cf create-service postgresql-10-odb standalone library-pg -c '
{
    "db_name": "library",
    "db_username": "dbaltor",
    "owner_name": "Denis Baltor",
    "owner_email": "dbaltor@vmware.com"
}'
cf create-service p-config-server standard config-server -c '{"git": { "uri": "https://github.com/dbaltor/config-repo", "refreshRate": 30 } }'
cf create-service p-service-registry standard service-registry
cf create-service p.gateway standard library-gateway -c '{ "host": "library-gtw" }'
until cf service library-ms | grep  "create succeeded"; do sleep 2; done
until cf service library-pg | grep  "create succeeded"; do sleep 2; done
until cf service config-server | grep  "create succeeded"; do sleep 2; done
until cf service service-registry | grep  "create succeeded"; do sleep 2; done
until cf service library-gateway | grep  "create succeeded"; do sleep 2; done

# Deploying microservices
cd ..
cf push

# Configuring network policies to allow container-to-container communications
cf add-network-policy library-msa library-reader-service
cf add-network-policy library-msa library-book-service
cf add-network-policy library-reader-service library-book-service
cf add-network-policy library-book-service library-reader-service

# cf CLI v6
#cf add-network-policy library-msa --destination-app library-reader-service
#cf add-network-policy library-msa --destination-app library-book-service
#cf add-network-policy library-reader-service --destination-app library-book-service
#cf add-network-policy library-book-service --destination-app library-reader-service