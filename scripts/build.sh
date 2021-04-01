#!/bin/sh
set -e
cd $(dirname $0)

cd ..

./gradlew clean reader:build -x test
ret=$?
if [ $ret -ne 0 ]; then
  exit $ret
fi

./gradlew reader:publishToMavenLocal
ret=$?
if [ $ret -ne 0 ]; then
  exit $ret
fi

./gradlew clean book:build -x test
ret=$?
if [ $ret -ne 0 ]; then
  exit $ret
fi

./gradlew book:publishToMavenLocal
ret=$?
if [ $ret -ne 0 ]; then
  exit $ret
fi

./gradlew build --parallel

exit
