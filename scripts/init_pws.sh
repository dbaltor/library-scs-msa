#!/bin/bash
set -e
cd $(dirname $0)

# Creating required service instances
cf create-service cleardb spark library-ms
cf create-service elephantsql turtle library-pg
cf create-service p-config-server trial config-server -c '{"git": { "uri": "https://github.com/dbaltor/config-repo", "refreshRate": 30 } }'
cf create-service p-service-registry trial service-registry
until cf service config-server | grep  "create succeeded"; do sleep 2; done
until cf service service-registry | grep  "create succeeded"; do sleep 2; done

# Creating api gateway
cd ../gateway
cf push
cd ..

# Deploying microservices
cf push

# Configuring network policies to allow container-to-container communications
cf add-network-policy library-msa --destination-app library-reader-service
cf add-network-policy library-msa --destination-app library-book-service
cf add-network-policy library-reader-service --destination-app library-book-service
cf add-network-policy library-book-service --destination-app library-reader-service
cf add-network-policy library-gtw --destination-app library-book-service
cf add-network-policy library-gtw --destination-app library-reader-service
