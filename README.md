Docker Private Repository の導入（ミラーリング機能付き）
=====================================================

centos7 へのインストールを想定しています。
ホスト＝proxy.altus5.local にインストールする手順になっています。

## デプロイ

./deploy.sh で配置します。
root で実行してください。

デプロイ先のディレクトリの構成は、このようなになります。
```
/opt
  /certs             ・・・SSLの証明書
    altus5.local.ca.pem        ・・・独自CAの証明書。すでに存在する場合は、上書きしません。
    altus5.local.ca-key.pem    ・・・同上
    proxy.altus5.local.pem     ・・・サーバー証明書。上書きします。
    proxy.altus5.local-key.pem ・・・同上
  /cfssl             ・・・SSLの証明書を作成するための設定ファイル
    /conf
      ca-config.json
      ca-csr.json
      proxy.altus5.local.json
  /docker-registry   ・・・Docker Registry を実行する場所
    /data              ・・・キャッシュしたイメージの保存場所
      config.yml         ・・・Docker Registryの設定ファイル
    
```

## 起動

```
cd /opt/docker-registry
docker-compose up -d
```
`docker-compose logs` でエラーがないことを、 確認します。

## クライアント側の設定

任意のクライアント端末で行います。  
dockerクライアントがプロキシーを向くための設定です。  
vagrantでvmを起動している場合は、vmの中で行ってください。  

### 独自CAの証明書インストール

証明書を取得します。
```
scp hoge@proxy.altus5.local:/opt/certs/ca.pem .
```

独自CAの証明書のインストールは、それぞれの環境に合わせて、行ってください。  
ここでは、centos7の場合について、説明します。
```
sudo cp ca.pem /usr/share/pki/ca-trust-source/anchors/altus5.local.ca.pem
sudo update-ca-trust extract
```

テストします。  
```
curl -I https://proxy.altus5.local:5000/v2/
```
`HTTP/1.1 200 OK` が表示されれば、OKです。もしも、`curl: (60) SSL certificate problem: unable to get local issuer certificate` と表示されたら、独自CAの証明書のインストールが間違っています。

### dockerデーモンの起動オプション設定

dockerデーモンの起動オプションを設定します。  
vi /etc/sysconfig/docker
```
OPTIONS='--selinux-enabled --log-driver=journald --signature-verification=false --registry-mirror=https://proxy.altus5.local:5000 --disable-legacy-registry=true'
```
OPTIONS に --registry-mirror と --disable-legacy-registry のオプションを、上記のとおり、追加設定します。  
設定後、再起動します。
```
sudo systemctl restart docker
```

テストします。  
先に、 docker-registry の方のログを流します。  
```
cd /opt/docker-registry
docker-compose logs -f
```
クライアント側で、pullしてみます。
```
sudo docker pull busybox:latest
```

クライアント側で、Pull complete と表示されて、 docker-registry の方のログにも、
エラーなく、ログが流れていれば、OKです。

