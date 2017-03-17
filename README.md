https://blog.docker.com/2015/10/registry-proxy-cache-docker-open-source/
https://docs.docker.com/registry/recipes/mirror/#configuring-the-cache
https://docs.docker.com/registry/recipes/mirror/#solution

## docker-registry の設定ファイルをcacheプロキシー用で作成する

docker-registry の config.yml を取り出して、cacheプロキシー用に、編集する

```
mkdir data
sudo docker run -it --rm --entrypoint cat registry:2.1 /etc/docker/registry/config.yml > ./data/config.yml
```

設定のポイントは、次の2点。
* http/tls にサーバー証明書のパスをセット
* proxy の設定を追加
編集後は、こんな感じになる。
```
version: 0.1
log:
  fields:
    service: registry
storage:
  cache:
    blobdescriptor: inmemory
  filesystem:
    rootdirectory: /var/lib/registry
http:
  addr: :5000
  tls:
    certificate: /certs/server.pem
    key: /certs/server-key.pem
  headers:
    X-Content-Type-Options: [nosniff]
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
proxy:
  remoteurl: https://registry-1.docker.io

```

## SSL証明書の作成

docker-registry を、ローカルホスト以外からも使う場合は、SSLにしないといけないので、
独自CAで証明書を作成する。

次のコンテナを使うと、素早く作成できます。あわせて、使ってみてください。
https://hub.docker.com/r/altus5/cfssl/

```
git clone https://github.com/altus5/docker-cfssl.git
cp -r docker-cfssl/example/cfssl .
rm -rf docker-cfssl
```

SSL証明書作成用の設定ファイルにサーバー名を追加する。  
vi cfssl/server.json
```
{
  "CN": "altus5",
  "hosts": [
    "proxy.altus5.local"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  }
}
```
上記の hosts のところに、サーバー名を設定する。  
そして、証明書を作成する。  
※証明書を作成し直す場合は、念のため、作成済ファイルを削除してから実行してください。( `rm cfssl/*pem && rm cfssl/*csr` )

```
sudo docker run --rm -it \
  -v $(pwd)/cfssl:/etc/cfssl \
  -v $(pwd)/cfssl:/opt/cfssl/conf \
  altus5/cfssl:0.5.0 \
  gen_server_cert.sh
```

サーバー証明書を登録する。  
(参考)
* https://docs.docker.com/registry/insecure/#troubleshooting-insecure-registry
```
sudo cp cfssl/ca.pem /usr/share/pki/ca-trust-source/anchors/altus5.local.ca.pem
sudo update-ca-trust extract

sudo cp cfssl/server.pem /etc/pki/ca-trust/source/anchors/proxy.altus5.local.com.crt
sudo update-ca-trust

sudo mkdir -p /etc/docker/certs.d/proxy.altus5.local:5000
sudo cp cfssl/server.pem /etc/docker/certs.d/proxy.altus5.local:5000/ca.crt
```

## docker-registry を配置する
```
# サーバー証明書の配置
sudo mkdir -p /opt/docker-registry/certs
sudo cp cfssl/server*pem /opt/docker-registry/certs
# storage用ディレクトリの作成
sudo mkdir -p /opt/docker-registry/data
# config.ymlの配置
sudo cp data/config.yml /opt/docker-registry/data
# docker-compose.ymlの配置
sudo cp docker-compose.yml /opt/docker-registry/
# docker-compose起動
sudo docker-compose -f /opt/docker-registry/docker-compose.yml up
```


## クライアント側の設定

独自CAの証明書を登録
```
sudo cp cfssl/ca.pem /usr/share/pki/ca-trust-source/anchors/altus5.local.ca.pem
sudo update-ca-trust extract
```

sudo vi /etc/sysconfig/docker
OPTIONS='--selinux-enabled --log-driver=journald --signature-verification=false --registry-mirror=https://proxy.altus5.local:5000 --disable-legacy-registry=true'


curl -I https://proxy.altus5.local:5000/v2/


sudo systemctl restart docker
sudo docker pull busybox:latest


