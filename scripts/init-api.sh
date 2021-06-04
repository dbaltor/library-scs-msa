#!/bin/bash
set -e
cd $(dirname $0)

# Creating required service instances
cf create-service p.config-server standard config-server -c '{"git": { "uri": "https://github.com/dbaltor/config-repo", "refreshRate": 30 } }'
cf create-service p.service-registry standard service-registry
cf create-service p.gateway standard library-gateway -c "{ \"host\": \"library-gtw\", \"cors\": { \"allowed-origins\": [ \"http://api.$(cf domains | awk '$1 ~ /^apps/ && $1 !~ /internal$/ { print $1}')\" ], \"allowed-methods\": [\"*\"], \"allowed-headers\": [\"*\"] } }"
#cf create-service p.gateway standard library-gateway -c '{ "host": "library-gtw", "cors": { "allowed-origins": [ "http://api.apps.fremont.cf-app.com" ], "allowed-methods": ["*"], "allowed-headers": ["*"] } }'
# CORS config required to allow API Portal to test the gateway
until cf service config-server | grep  "create succeeded"; do sleep 2; done
until cf service service-registry | grep  "create succeeded"; do sleep 2; done
until cf service library-gateway | grep  "create succeeded"; do sleep 2; done

# Deploying microservices
cd ..
cf push -f manifest-api.yml

# API Portal
cf push api -p api-portal-for-vmware-tanzu-1.0.0/jars/api-portal-server-1.0.0.jar -b java_buildpack_offline --no-manifest --no-start
cf set-env api API_PORTAL_SOURCE_URLS "`cf service-brokers | awk '$1 ~ /scg-service-broker/ {print $2}'`/openapi"
# cf set-env api API_PORTAL_SOURCE_URLS https://scg-service-broker.sys.fremont.cf-app.com/openapi ## ${brokerUrl}/openapi where brokerUrl is from `cf service-brokers`
cf start api

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
