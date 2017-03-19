#!/bin/bash

basedir=$(cd $(dirname $0) && pwd)

cd $basedir

mkdir -p /opt/cfssl/conf
\cp -rf cfssl/* /opt/cfssl/conf

mkdir -p /opt/docker-registry
\cp -rf docker-registry/* /opt/docker-registry/

# 証明書を作成
docker run --rm -it \
  -v /opt/cfssl/conf:/opt/cfssl/conf \
  -v /opt/certs:/opt/certs \
  -e "CERT_DIR=/opt/certs" \
  -e "CA_CERT_PREFIX=/opt/certs/altus.local.ca" \
  -e "SERVER_CONF=/opt/cfssl/conf/proxy.altus.local.json" \
  -e "SERVER_CERT_PREFIX=/opt/certs/proxy.altus.local" \
  altus5/cfssl:0.5.2 \
  gen_server_cert.sh

# 起動
#cd /opt/docker-registry
#docker-compose up -d

