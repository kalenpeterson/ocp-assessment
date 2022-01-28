#!/bin/bash

docker build -t docker.io/kalenpeterson/pbench:20.04 -f Passmark-Dockerfile . || exit 1

docker push docker.io/kalenpeterson/pbench:20.04 || exit 1

echo "Build OK"