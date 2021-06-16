#!/bin/bash
set -e
cd $(dirname $0)

# Verify whether or not API Portal is to be deployed
API_PORTAL_PATH=$1
if [[ $# -eq 0 ]]; then
    read -n 1 -p "No path to API Portal jar file has been informed. Do you wish to continue without an API Portal?" answer
    echo ""
    case ${answer:0:1} in
        y|Y )
            echo Yes
        ;;
        * )
            echo No
            read -rep $'Please type in the path to API Portal jar file:\n' API_PORTAL_PATH
        ;;
    esac
fi

# Creating required service instances
cf create-service p.config-server standard config-server -c '{"git": { "uri": "https://github.com/dbaltor/config-repo", "refreshRate": 30, "periodic": true} }'
cf create-service p.service-registry standard service-registry
cf create-service p.gateway standard library-gateway -c "{ \"title\": \"Library APIs\", \"description\": \"Set of RESTful APIs offered by Reader and Book services.\", \"host\": \"library-gtw\", \"cors\": { \"allowed-origins\": [ \"http://api.$(cf domains | awk '$1 ~ /^apps/ && $1 !~ /internal$/ { print $1}')\" ], \"allowed-methods\": [\"*\"], \"allowed-headers\": [\"*\"] } }"
#cf create-service p.gateway standard library-gateway -c '{ "host": "library-gtw", "cors": { "allowed-origins": [ "http://api.apps.fremont.cf-app.com" ], "allowed-methods": ["*"], "allowed-headers": ["*"] } }'
# CORS config required to allow API Portal to connect to this gateway
until cf service config-server | grep  "create succeeded"; do sleep 2; done
until cf service service-registry | grep  "create succeeded"; do sleep 2; done
until cf service library-gateway | grep  "create succeeded"; do sleep 2; done

# Deploying microservices
cd ..
cf push -f manifest-api.yml

# Deploy API Portal (Optional)
if [[ -n $API_PORTAL_PATH ]]; then
    cf push api -p $API_PORTAL_PATH -b java_buildpack_offline --no-manifest --no-start
    #cf push api -p api-portal-for-vmware-tanzu-1.0.0/jars/api-portal-server-1.0.0.jar -b java_buildpack_offline --no-manifest --no-start
    cf set-env api API_PORTAL_SOURCE_URLS "`cf service-brokers | awk '$1 ~ /scg-service-broker/ {print $2}'`/openapi, https://petstore3.swagger.io/api/v3/openapi.json"
    # cf set-env api API_PORTAL_SOURCE_URLS https://scg-service-broker.sys.fremont.cf-app.com/openapi ## ${brokerUrl}/openapi where brokerUrl is from `cf service-brokers`
    cf start api
fi

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
