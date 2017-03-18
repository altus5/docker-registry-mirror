#!/bin/bash

basedir=$(cd $(dirname $0) && pwd)

cd $basedir

mkdir -p /opt/cfssl
cp -rf cfssl/ /opt/cfssl/

mkdir -p /opt/docker-registry
cp -rf docker-registry/ /opt/docker-registry/

# 証明書を作成
docker run --rm -it \
  -v /opt/cfssl:/etc/cfssl \
  -v /opt/cfssl:/opt/cfssl/conf \
  -v /opt/cfssl/proxy.altus.local.json:/opt/cfssl/conf/server.json \
  -v /opt/certs/proxy.altus.local.csr:/opt/cfssl/conf/server.csr \
  -v /opt/certs/proxy.altus.local.pem:/opt/cfssl/conf/server.pem \
  -v /opt/certs/proxy.altus.local-key.pem:/opt/cfssl/conf/server-key.pem \
  -v /opt/certs/altus.local.ca.csr:/opt/cfssl/conf/ca.csr \
  -v /opt/certs/altus.local.ca.pem:/opt/cfssl/conf/ca.pem \
  -v /opt/certs/altus.local.ca-key.pem:/opt/cfssl/conf/ca-key.pem \
  altus5/cfssl:0.5.1 \
  gen_server_cert.sh

# 起動
cd /opt/docker-registry
docker-compose up -d

