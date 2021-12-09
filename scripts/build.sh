#!/bin/sh
set -e
cd $(dirname $0)

cd ..

./gradlew reader:publishToMavenLocal
#ret=$?
#if [ $ret -ne 0 ]; then
#  exit $ret
#fi

./gradlew book:publishToMavenLocal

./gradlew build --parallel

exit
