---
layout: post
title: "Sensuの監視の設定"
published: true
date: "2014-05-03T02:59:00+09:00"
comments: true


---

[Sensu導入と初期設定について](http://blog.kenjiskywalker.org/blog/2014/05/02/newbie-sensu/)の続きのエントリーになります。

### pluginの書き方

[http://sensuapp.org/docs/0.12/checks](http://sensuapp.org/docs/0.12/checks)  
[http://sensuapp.org/docs/0.12/adding_a_check](http://sensuapp.org/docs/0.12/adding_a_check)

上記ドキュメントを参考にして頂くとわかる通り

- status code が`0`であれば`OK`  
- status code が`1`であれば`WARNING`
- status code が`2`であれば`CRITICAL`
- status code が`3`であれば`UNKNOWN`

という方法で監視を行います。  
  
コミュニティプラグインを確認すると、そのほとんどが  
`require 'sensu-plugin/check/cli'`を呼び出していることがわかります。  
  
### [https://github.com/sensu/sensu-plugin](https://github.com/sensu/sensu-plugin)  
  
check用のメソッド、metrics用のメソッドを  
それぞれ利用することが可能になります。  
まだ私はpluginを書いたことがないので、また書く機会があれば  
その時に改めて詳細を書きたいと思います。  
  
### 気を付けなければならないこと  
  
導入以前は、Sensuはアラートとメトリクスのデータを  
同じデータを利用して監視を行うことができると考えていたのですが  
これは誤りで、  

- checkはcheck用のプラグイン
- metricsはmetircs用のプラグイン
  
と分かれています。なかなかZABBIXのように万能にはいかないようです。  
  
## checks

```
{
  "checks": {
    "check_cpu": {
      "command": "/etc/sensu/plugins/check-cpu.rb -w 90 -c 100",
      "interval": 60,
      "occurrences": 5,
      "subscribers": ["all"],
      "handlers": ["hipchat", "mailer"]
    }
  },
  "checks": {
    "check_cpu_nervous": {
      "command": "/etc/sensu/plugins/check-cpu.rb -w 10 -c 30",
      "interval": 60,
      "subscribers": ["admin"],
      "handlers": ["hipchat", "mailer"]
    }
  }
}
```

- "check_cpu", "check_cpu_nervous"

設定内容の名前です。  
Sensuは設定内容のjsonがdeep_mergeされるので、ここはユニークな値にしてください。  
よくあるミスとして、利用するプラグインは同じで  
上記のように設定内容が微妙に違うという場合、元のファイルをコピーし  
名前を変更するのを忘れて上書きされてしまい  
設定ファイルを作成したのに上手く認識されない。ということがよくあります。

- "commnand" 

実行するコマンドです。status codeとSTDOUT,STDERRのどちらかが返ってくれば、  
Rubyでなくとも、シェルスクリプトやGo、pythonなど何を利用しても問題ありません。  
nagios pluginと設定を合わせている為、nagiosのpluginを利用することが可能です。  
  
- "interval"

コマンドを実行する間隔です。

- "occurrences"

監視通知の閾値です。例えば`occurrences`が`3`に設定されていた場合  
_3回継続してアラートの条件を満たした場合にアラート通知する。_  
という条件になります。デフォルトは`1`で、1回でも  
アラートの条件を満たしたら通知が行われます。  
  
- "subscribers"

ここでホストとアラートの紐付けを行います。  
client側で設定されている`subscriptions`を見て  
`subscribers`と同じであれば、その監視を行う条件を満たし  
監視コマンドが実行されるようになります。

- "handlers"

アラートの条件を満たしていた場合の通知先の設定です。  
上記設定例でいうと、HipChatとmailを利用します。  
通知先の設定内容はSensu server側にて行います。  

- /etc/sensu/conf.d/handlers/hipchat.json

```
{
  "handlers": {
    "hipchat": {
      "type": "pipe",
      "command": "/etc/sensu/handlers/hipchat.rb"
    }
  },
  "hipchat": {
    "apikey": "APIKEY",
    "apiversion": "v1",
    "room": "ROOM_NAME",
    "from": "FROM_NAME"
  }
}
```

- /etc/sensu/conf.d/handlers/mailer.json

```
{
  "handlers": {
    "mailer": {
      "type": "pipe",
      "command": "/etc/sensu/handlers/mailer.rb"
    }
  },
  "mailer": {
    "mail_from": "sensu@example.com",
    "mail_to": "alert@example.com",
    "smtp_address": "192.0.2.100",
    "smtp_port": "25",
    "smtp_domain": "example.com"
  }
}
```

上記のような設定を行います。  


## metircs

checkとの違いは`"type": "metric"`の有無の違いのみ。  
`"type": "metric"`が存在すると_handle_event_メソッドを実行します。

- /etc/sensu/conf.d/metrics/metrics-cpu.json

```
{
  "checks": {
    "metrics_cpu_pcnt-usage": {
      "type": "metric",
      "command": "/etc/sensu/plugins/cpu-pcnt-usage-metrics.rb --scheme stats.:::name:::.cpu",
      "interval": 60,
      "subscribers": [ "all" ],
      "handlers": ["graphite"]
    }
  }
}
```

- "command"

基本的にmetircs系のプラグインはschemeの設定が可能になっている。  
これは大変便利で、上記設定例でいうと  
`stats.hostname.cpu.cpu_pcnt.*`のように
スキーマを定義することが可能になります。  

- /etc/sensu/conf.d/handlers/graphite.json

```
{
  "handlers": {
    "graphite": {
      "type": "tcp",
      "socket": {
        "host": "127.0.0.1",
        "port": 2003
      },
      "mutator": "only_check_output"
    }
  }
}
```

上記graphiteの設定は、_pipe_、_tcp_や_udp_などを利用し  
handlerへ渡すことが可能なので、それを利用した設定内容になります。

- "mutator": "only_check_output"

`only_check_output.rb`を見る限り、  
`check`の結果を`0`で返す(checkを行わない)オプションのようです。  
  

## client 

- /etc/sensu/conf.d/client.json

> _/etc/sensu/conf.d/_ディレクトリ配下であれば  
> clientの設定のファイル名に決まりはありません。

```
{
  "client": {
    "name": "client_name",
    "address": "192.0.2.10",
    "subscriptions": ["all", "admin", "foo"]
  }
}
```

- "name"

Sensu clientの名前です。

- "address"

Sensu clientのアドレスです。  
IPアドレスでもDNS名でも何でも良いです。誤っていたからといって  
Sensu serverと接続できなくなるということはありません。

- "subscriptions"

Sensu server側で行ったcheck、metricsに対する関連付けです。  
関連付けされる対象は`subscribers`です。  
  
## 五月雨式ではありますが  
  
監視をする上での細かい設定内容の解説でした。  
ドキュメントを読み進める上でのお役に立てれば幸いです。  
