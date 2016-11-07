---
layout: post
title: "Sensu導入と初期設定について"
published: true
date: "2014-05-02T14:48:00+09:00"
comments: true


---

> Chef: 11.8.0  
> sensu: 0.12.3  
> RabbitMQ: 3.1.5  
> erlang R14B-04.1.4  
> Redis :2.6.17

## 参考 : 

[監視ソフトをNagiosからSensuに切り替えて2ヶ月経ったのでまとめた - Glide Note](http://blog.glidenote.com/blog/2013/11/26/sensu/)  
[Amazon Linux 上に sensu-server を構築する（1）- ようへいの日々精進 XP](http://inokara.hateblo.jp/entry/2014/03/03/013147)  

特にようへいさんのブログはSensuのエントリーが多く、大変参考になります。  
ありがとうございます。

## Sensu server + Sensu client のインストール

Chefを利用します。  
インストール自体は[RabbitMQでコケる記事](http://blog.kenjiskywalker.org/blog/2014/01/05/sensu-centos6-4-erlang-install/)を参考にして下さい。  
2014/05/02 現在、RabbitMQのインストールで失敗することはなくなりました。
また、下記に記載しますが、インストール先サーバのRubyのバージョンに環境が左右されないように  
`"use_embedded_ruby": true`としてembedded rubyを利用することをおすすめいたします。

#### tips 
[sensu-chef から include_recipe"yum" 外す](https://github.com/kenjiskywalker/sensu-chef/commit/9377295e8c5fabf9631104b52a84ee6d10683383)

基本的にsensuをインストールするのに既存のものを破壊することはないのですが  
`sensu-chef`の中に__include_recipe "yum"__しているところがあり  
この設定をよしなにしないと`yum.conf`が書き換えられてしまいます。  
  
sensuのインストールは`sensu.repo`を追加して行うので「include_recipe "yum"」は不要です。  
既存のサーバにインストールするときは気を付けて下さい。

この前[ryuzeeさんのpull request](https://github.com/sensu/sensu-chef/pull/235)が取り込まれて  
Amazon Linuxにインストールすることができるようになりました。

- sensu_server.json

sensuとredisとrabbitmqをインストールしてください。  

- sensu_server.json

```
{
  "sensu": {
      "use_embedded_ruby": true,
      "dashboard": {
          "user": "foo",
          "password": "bar"
      },
       "rabbitmq": {
          "host": "localhost",
          "port": 5671,
          "vhost": "/sensu",
          "password": "baz"
      },
      "node_subscriptions": [
          "sensu_server"
      ]
  },
  "run_list": ["recipe[sensu]", "recipe[sensu::redis]", "recipe[sensu::rabbitmq]"]
}
```

上記内容でChefを廻せばインストールされるかと思います。  
パスワードやポートなどデフォルトの設定のままで問題なければ指定は不要です。  
  


## Sensu client のインストール

clientはsensu-clientだけが動いていれば大丈夫です。  

- sensu_client.json

```
{
  "sensu": {
        "use_embedded_ruby": true,
        "node_subscriptions": [ "sensu_client" ],
        "use_embedded_ruby": true,
        "rabbitmq": {
              "host": "sensu-server",
              "port": 5671,
              "vhost": "/sensu",
              "password": "baz"
          }

    }
  },
  "run_list": ["recipe[sensu]"]
}
```

上記内容でChefを廻せばインストールされるかと思います。  
パスワードやポートなどデフォルトの設定のままで問題なければ指定は不要です。  
 

## Sensu serverの設定


Chefの動作が問題なければ`/etc/sensu/config.json`のファイルが作成されているかと思います。  

```
$ /etc/init.d/sensu-server start
$ tail -F /var/log/sensu/sensu-server.log
```

起動できることを確認してください。  
最初、すごい勘違いしていたのですが、sensu-apiはdashboardの為の機能で  
sensu-serverには必要ないと思っていたのですが、基本的なミドルウェア間のやり取りは  
sensu-apiを通して利用することになります。なので


```
$ /etc/init.d/sensu-api start
$ tail -F /var/log/sensu/sensu-api.log
```

として、sensu-apiを起動してください。  
これでsensu-clientからデータを受け付ける準備ができました。


## Sensu clientの設定

[https://github.com/kenjiskywalker/sensu-client-plugin](https://github.com/kenjiskywalker/sensu-client-plugin)

多分みなさんこのような自前recipeを作成しているかと思いますが  
上記のrecipeを利用して`/etc/sensu/conf.d/client.json`という  
client用のjsonファイルを作成します。  
  
pluginの配布も上記cookbookを利用して配布しようかなと考えていますが  
Chefの実行自体のコストが地味に大きいので、配布自体はrsyncか何かで配布して  
Chefで冪等性を確保するのが効率良いのかなとも考えています。  

```
$ /etc/init.d/sensu-client start
$ tail -F /var/log/sensu/sensu-client.log
```

## 監視項目の追加(server)

- 監視に利用するプラグインのコマンド置き場

`/etc/sensu/plugins/`

- 通知に利用するプラグインのコマンド置き場

`/etc/sensu/handlers/`


- 監視内容の設定・通知の設定など

`/etc/sensu/conf.d/`


## ファイル構成

- server

```
/etc/sensu/
├── conf.d
│   ├── checks
│   │   ├── check_cpu.json
│   │   ├── check_disk.json
│   │   ├── check_mailq.json
│   │   ├── check_memcached.json
│   │   ├── check_mongodb.json
│   │   ├── check_mongodb_replica.json
│   │   ├── check_proc_apache.json
│   │   ├── check_proc_nginx.json
│   │   ├── check_redis_info.json
│   │   ├── check_redis_info_slave.json
│   │   ├── check_smtp.json
│   ├── handlers
│   │   ├── graphite.json
│   │   ├── hipchat.json
│   │   └── mailer.json
│   ├── metrics
│   │   ├── metrics-cpu.json
│   │   ├── metrics-disk_usage.json
│   │   ├── metrics-net.json
│   │   ├── metrics-netstat-tcp.json
│   │   └── metrics-vmstat.json
│   └── README.md
├── config.json
├── extensions
├── handlers
│   ├── hipchat.rb
│   └── mailer.rb
├── mutators
├── plugins
└── ssl
    ├── cert.pem
    └── key.pem
```

Sensu serverを監視しないとういことはないので  
`/etc/sensu/plugins/`配下に監視用のコマンドを起きますが  
Sensu serverが動く最低限の設定例を記載します。  
  
Sensu serverはSensu clientにこれを実行してねという機能を持ち  
Sensu clientはserverから受け取ったjobを実行し  
serverへ結果を返す。という繰り返しを行います。  


- client

```
/etc/sensu/
├── conf.d
│   ├── client.json
│   └── README.md
├── config.json
├── extensions
├── handlers
├── mutators
├── plugins
│   ├── check-cpu.rb
│   ├── check-disk.rb
│   ├── check-http.rb
│   ├── check-mailq.rb
│   ├── check-memcached-stats.rb
│   ├── check_mongodb.py
│   ├── check_mongo_replica_stat.rb
│   ├── check-procs.rb
│   ├── check-redis-info.rb
│   ├── cpu-pcnt-usage-metrics.rb
│   ├── disk-usage-metrics.rb
│   ├── metrics-net.rb
│   ├── metrics-netstat-tcp.rb
│   └── vmstat-metrics.rb
└── ssl
    ├── cert.pem
    └── key.pem
```


### Sensu server

- 監視の設定は必要(_/etc/sensu/conf.d/etc/_)
- 監視のコマンドは必要ない(_/etc/sensu/plugins/_)


### Sensu client

- 監視の設定は必要ない(_/etc/sensu/conf.d/etc/_)
- 監視のコマンドは必要(_/etc/sensu/plugins/_)


ということになります。  
  
まだ完全に動作を理解してるわけではないので  
次はもう少し確認した後、監視の仕組みについてまとめたいと思います。
