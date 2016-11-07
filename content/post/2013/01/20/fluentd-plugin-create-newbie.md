---
layout: post
title: "fluentdのプラグインを書く練習をする為にsecureログをparseしてZabbixで値が取得できるようにしてみた(設定編)"
published: true
date: "2013-01-20T18:56:00+09:00"
comments: true


---

[https://github.com/kenjiskywalker/fluent-plugin-securelog-parser](https://github.com/kenjiskywalker/fluent-plugin-securelog-parser)

<pre>
   ,j;;;;;j,. ---一､ ｀   ―--‐､_ l;;;;;;  
  ｛;;;;;;ゝ T辷iﾌ i      f'辷jァ   !i;;;;;    全く触ったことがなくてもpluginを書いたらfluentdがわかる  
   ヾ;;;ﾊ        ﾉ              .::!lﾘ;;rﾞ  
     `Z;i      〈.,_..,.            ﾉ;;;;;;;;>    そんなふうに考えていた時期が  
     ,;ぇﾊ、  ､_,.ｰ-､_',.      ,ｆﾞ: Y;;f.      俺にもありました  
     ~''戈ヽ    ｀二´      r'´:::.  `!  
</pre>

最初Postfixのmaillogつくってやろうかなんて  
思っていたりした時期もオレにはありました。

しかしログが多様すぎるので、ちょっとこれ最初にやるには敷居高いなー  
と思い、だからってあんまり理にかなわないことをしても意味ないな  
ということで、`/var/log/secure`のログを指定した文字列の出現具合を  
Zabbixで取得したら面白いかなというアイデアが思いついたので  
取り敢えずコードは汚いにしろ、動くまで書いてみたメモです。  

[プラグイン作成編はこちらから](http://blog.kenjiskywalker.org/blog/2013/01/20/fluentd-plugin-create-newbiee/)


## テスト環境

`/etc/fluent-agent-lite.conf`
```
/etc/fluent-agent-lite.conf 
TAG_PREFIX=""
LOGS=$(cat <<"EOF"
secure                   /var/log/secure
EOF
)
PRIMARY_SERVER="0.0.0.0:24224"
```


`/etc/td-agent/td-agent.conf`

```
<source>
  type forward
  port 24224
</source>

<match secure>
  type securelog-parser
  tag  seclog.local
</match>

<match seclog.*>
  type copy
   <store>
    type datacounter
    count_key message
    aggregate all
    tag check.seclog
    pattern1 acce Accepted
    pattern2 fail failure
    pattern3 inva Invalid
  </store>
  <store>
   type file
   path /tmp/hoge
  </store>
</match>

<match check.**>
  type copy
  <store>
    type file
    path /var/log/td-agent/check_seclog
  </store>
  <store>
    type             zabbix
    zabbix_server    192.0.2.2
    host             watashi
    name_key_pattern (fail|acce|inva)_count
    add_key_prefix   securelog
  </store>
</match>
```

## 環境および設定内容の解説

## `fluent-agent-lite` 

`in_tail`で見に行くとパーミッションが足りないとのことなので  
fluent-agent-liteを噛ましました。  

localhostに転送するので
`PRIMARY_SERVER="0.0.0.0:24224"`として自分自身へ転送。

## `td-agent`

`fluent-agent-lite`から値を取得。
```
<source>
  type forward
  port 24224
</source>
```

### 自作pluginを通す

`fluent-agent-lite`で付与した`secure`のタグをmatchさせて  
自作したテスト用のpluginへ渡します。
```
<match secure>
  type securelog-parser
  tag  seclog.local
</match>
```

### fluent-plugin-datacounterを通す

`seclog.*`にmatchさせ  
 
もりす先生の[fluent-plugin-datacounter](https://github.com/tagomoris/fluent-plugin-datacounter)を利用し  
それぞれ確認したいログのpatternを登録します。

```
<match seclog.*>
  type copy
   <store>
    type datacounter
    count_key message
    aggregate all
    tag check.seclog
    pattern1 acce Accepted
    pattern2 fail failure
    pattern3 inva Invalid
  </store>
  <store>
   type file
   path /tmp/hoge
  </store>
</match>
```

 - `pattern1 acce Accepted`  
接続が許可されたログ(Acceptedという文字列を含んだログ)を  
*pattern1*として*acce*というprefixで渡します。

 - `pattern2 fail failure`  
接続に失敗したログ(failureという文字列を含んだログ)を  
*pattern2*として*fail*というprefixで渡します。

 - `pattern3 inva Invalid`  
無効な接続のログ(Invalidという文字列を含んだログ)を  
*pattern3*として*inva*というprefixで渡します。

また、デバッグの為に、`/tmp/hoge`ファイルへ  
現時点での状態をファイル出力しておきます。

```
2013-01-20T18:12:24+09:00       seclog.local    {"message":"Accepted publickey for hogehoge from 192.0.2.100 port 64884 ssh2"}
2013-01-20T18:12:24+09:00       seclog.local    {"message":"pam_unix(sshd:session): session opened for user hogehoge by (uid=0)"}
2013-01-20T18:12:28+09:00       seclog.local    {"message":"Received disconnect from 192.0.2.100: 11: disconnected by user"}
```
上記のような内容で、出力されています。  
この時点で期待した内容のログ出力がされていない場合は  
どこかに誤りがあるので、修正していく流れになります。

### fluent-plugin-zabbixへデータを渡す

fujiwaraさん作成の[fluent-plugin-zabbix](https://github.com/fujiwara/fluent-plugin-zabbix)を利用し、Zabbixへデータを渡します。
  

```
<match check.**>
  type copy
  <store>
    type file
    path /var/log/td-agent/check_seclog
  </store>
  <store>
    type             zabbix
    zabbix_server    192.0.2.2
    host             watashi
    name_key_pattern (fail|acce|inva)_count
    add_key_prefix   securelog
  </store>
</match>
```

`/tmp/hoge`へのデバッグ出力と同様に  
*fluent-plugin-datacounter*を通したログを  
`/var/log/td-agent/check_seclog`へ出力しておきます。
```
  <store>
    type file
    path /var/log/td-agent/check_seclog
  </store>
```
こちらも、値が正常に取得されているかを確認します。
```
2013-01-20T18:09:56+09:00       check.seclog    {"unmatched_count":4,"unmatched_rate":0.06,"unmatched_percentage":66.66666666666667,"acce_count":0,"acce_rate":0.0,"acce_percentage":0.0,"fail_count":0,"fail_rate":0.0,"fail_percentage":0.0,"inva_count":2,"inva_rate":0.03,"inva_percentage":33.333333333333336}
2013-01-20T18:10:56+09:00       check.seclog    {"unmatched_count":0,"unmatched_rate":0.0,"acce_count":0,"acce_rate":0.0,"fail_count":0,"fail_rate":0.0,"inva_count":0,"inva_rate":0.0}
2013-01-20T18:11:56+09:00       check.seclog    {"unmatched_count":0,"unmatched_rate":0.0,"acce_count":0,"acce_rate":0.0,"fail_count":0,"fail_rate":0.0,"inva_count":0,"inva_rate":0.0}
2013-01-20T18:12:56+09:00       check.seclog    {"unmatched_count":14,"unmatched_rate":0.23,"unmatched_percentage":73.6842105263158,"acce_count":4,"acce_rate":0.06,"acce_percentage":21.05263157894737,"fail_count":0,"fail_rate":0.0,"fail_percentage":0.0,"inva_count":1,"inva_rate":0.01,"inva_percentage":5.2631578947368425}
```

 - `zabbix_server    192.0.2.2`
zabbixサーバのIPアドレスを指定します。

 - `host             watashi`
データ送り元のホスト名を指定します。

 - `name_key_pattern (fail|acce|inva)_count`  
*name_key_pattern (fail|acce|inva)_count*の設定と  
*add_key_prefix   securelog*の設定は  

[![zabbix](https://dl.dropbox.com/u/5390179/6c2da543eb8312cd496ef8f75fb8d83d.png)](https://dl.dropbox.com/u/5390179/6c2da543eb8312cd496ef8f75fb8d83d.png)

Zabbixで、itemを上記設定のように作成し  
trapperのデータとしてZabbixが受け取れる為に設定します。

### Zabbixでグラフ化

Zabbix上で上手く値が取得できていれば

[![zabbix](https://dl.dropbox.com/u/5390179/107d6802dbac9f28c4b78819242d3018.png)](https://dl.dropbox.com/u/5390179/107d6802dbac9f28c4b78819242d3018.png)

このようにグラフに値が出力され、期待通りの動作をすることが確認できました。

awesome fluentd!
