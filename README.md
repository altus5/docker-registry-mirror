Docker Private Repository （ミラーリング機能付き）
================================================

centos7 で実行することを想定しています。  
ホスト名は、 proxy.altus.local でセットアップします。

## デプロイ

./deploy.sh を実行すると、デプロイします。
root で実行してください。

デプロイ先のディレクトリの構成は、このようなになります。
```
/opt
  /certs             ・・・SSLの証明書
    altus.local.ca.pem        ・・・独自CAの証明書。すでに存在する場合は、上書きしません。
    altus.local.ca-key.pem    ・・・同上
    proxy.altus.local.pem     ・・・サーバー証明書。上書きします。
    proxy.altus.local-key.pem ・・・同上
  /cfssl             ・・・SSLの証明書を作成するための設定ファイル
    ca-config.json
    proxy.altus.local.json
  /docker-registry   ・・・Docker Registry を実行する場所
    /data              ・・・キャッシュしたイメージの保存場所
      config.yml         ・・・Docker Registryの設定ファイル
    
```

## 起動

```
cd /opt/docker-registry
docker-compose up -d
```

