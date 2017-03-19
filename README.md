Docker Private Repository の導入（ミラーリング機能付き）
=====================================================

centos7 で実行することを想定しています。  
ホスト名は、 proxy.altus5.local でセットアップします。

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

任意のクライアント端末から、次のコマンドを実行して、接続できればOK

