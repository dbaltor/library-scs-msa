#!/bin/bash
set -e

cf delete library-msa -f -r
cf delete library-reader-service -f -r
cf delete library-book-service -f -r
cf delete-service library-ms -f
cf delete-service library-pg -f
cf delete-service service-registry -f
cf delete-service config-server -f
cf delete-service library-gateway -f