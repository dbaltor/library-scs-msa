#!/bin/bash
set -e

cf delete library-msa -f -r
cf delete library-reader-service -f -r
cf delete library-book-service -f -r

API_PORTAL_APP=$(cf apps | awk '$1 ~ /api/ {print $0}')
if [ -n "$API_PORTAL_APP" ]; then 
    cf delete api -f -r
fi

cf delete-service service-registry -f
cf delete-service config-server -f
cf delete-service library-gateway -f

#cf remove-network-policy library-msa library-reader-service --protocol tcp --port 8080
#cf remove-network-policy library-msa library-book-service --protocol tcp --port 8080
#cf remove-network-policy library-reader-service library-book-service --protocol tcp --port 8080
#cf remove-network-policy library-book-service library-reader-service --protocol tcp --port 8080