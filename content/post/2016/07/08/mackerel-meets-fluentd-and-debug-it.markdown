---
layout: post
title: "問題があったのでfluentdでsigdumpを使いstactraceしてmackerel-client-rubyにPRした話"
published: true
date: "2016-07-08T12:45:00+09:00"
comments: true


---
みんなのネットワーク環境が安定しているのか..  
我々の世界線にノイズが混在してしまっているのか...  
  
それを調べるすべはないが、下記のような問題があった。

- `mackerel`で突然グラフが表示されなくなる
- そのグラフを表示しているのは`fluent-plugin-mackerel`を利用して`fluentd`経由で作成している
- その`td-agent`は再起動しようとすると`Timeout error`になる

ということで怪奇現象を解決する為にやったことをメモ


### 愚直に`td-agent`の再起動を試みてみる

```
[watashi@example-host ~]$ 
[watashi@example-host ~]$ 
[watashi@example-host ~]$ sudo service td-agent restart
Restarting td-agent:

Timeout error occurred trying to stop td-agent...                                          [  OK  ]
[watashi@example-host ~]$ 
```

ダメや

fluentdのコミッターの[@sonots](https://twitter.com/sonots)さんに

- ログは出ない  
- デーモンは生きている

そんな現象に出会ったことない？と聞いたところ   
fluentdには[sigdump](https://github.com/frsyuki/sigdump)が入っているから  
そこでstacktraceを追ってみれば、と意識の高いお返事を頂いたので実行してみる。

#### kill -CONT

[ドキュメント](https://github.com/frsyuki/sigdump#usage)に書いてあるように`CONT`のシグナルを送る

```
[watashi@example-host ~]$ ps auxwwwf | grep td-agent
td-agent  7779  0.0  0.3 241756 26700 ?        Sl   May27   0:00 /opt/td-agent/embedded/bin/ruby /usr/sbin/td-agent --log /var/log/td-agent/td-agent.log --use-v1-config --group td-agent --daemon /var/run/td-agent/td-agent.pid
td-agent  7915  0.3  3.7 838976 288956 ?       Sl   May27 225:44  \_ /opt/td-agent/embedded/bin/ruby /usr/sbin/td-agent --log /var/log/td-agent/td-agent.log --use-v1-config --group td-agent --daemon /var/run/td-agent/td-agent.pid
[watashi@example-host ~]$ 
[watashi@example-host ~]$ sudo kill -CONT 7915
[watashi@example-host ~]$ 
[watashi@example-host ~]$ ps auxwwwf | grep td-agent
td-agent  7779  0.0  0.3 241756 26836 ?        Sl   May27   0:00 /opt/td-agent/embedded/bin/ruby /usr/sbin/td-agent --log /var/log/td-agent/td-agent.log --use-v1-config --group td-agent --daemon /var/run/td-agent/td-agent.pid
td-agent  7915  0.3  3.7 838976 288956 ?       Sl   May27 225:44  \_ /opt/td-agent/embedded/bin/ruby /usr/sbin/td-agent --log /var/log/td-agent/td-agent.log --use-v1-config --group td-agent --daemon /var/run/td-agent/td-agent.pid
[watashi@example-host ~]$
```

#### sigdumpができあがっている

```
[watashi@example-host ~]$ ls -la /tmp/
total 1048
-rw-rw-rw-  1 td-agent td-agent    5937 Jul  7 10:51 sigdump-7915.log
[watashi@example-host ~]$
```

#### sigdumpの中身を見てみる

```
[watashi@example-host ~]$ sudo view /tmp/sigdump-7915.log
Sigdump at 2016-07-07 10:52:00 +0900 process 7915 (/usr/sbin/td-agent)
  Thread #<Thread:0x007fce4f19e658> status=run priority=0
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/sigdump-0.2.3/lib/sigdump.rb:39:in `backtrace'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/sigdump-0.2.3/lib/sigdump.rb:39:in `dump_backtrace'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/sigdump-0.2.3/lib/sigdump.rb:25:in `block in dump_all_thread_backtrace'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/sigdump-0.2.3/lib/sigdump.rb:24:in `each'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/sigdump-0.2.3/lib/sigdump.rb:24:in `dump_all_thread_backtrace'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/sigdump-0.2.3/lib/sigdump.rb:16:in `block in dump'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/sigdump-0.2.3/lib/sigdump.rb:119:in `open'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/sigdump-0.2.3/lib/sigdump.rb:119:in `_open_dump_path'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/sigdump-0.2.3/lib/sigdump.rb:14:in `dump'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/sigdump-0.2.3/lib/sigdump.rb:7:in `block in setup'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/agent.rb:102:in `call'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/agent.rb:102:in `join'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/agent.rb:102:in `block in shutdown'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/agent.rb:102:in `each'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/agent.rb:102:in `shutdown'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/root_agent.rb:131:in `block in shutdown'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/root_agent.rb:130:in `each'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/root_agent.rb:130:in `shutdown'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/engine.rb:229:in `shutdown'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/engine.rb:200:in `run'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/supervisor.rb:597:in `run_engine'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/supervisor.rb:148:in `block in start'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/supervisor.rb:352:in `call'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/supervisor.rb:352:in `main_process'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/supervisor.rb:325:in `block in supervise'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/supervisor.rb:324:in `fork'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/supervisor.rb:324:in `supervise'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/supervisor.rb:142:in `start'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/command/fluentd.rb:171:in `<top (required)>'
      /opt/td-agent/embedded/lib/ruby/site_ruby/2.1.0/rubygems/core_ext/kernel_require.rb:54:in `require'
      /opt/td-agent/embedded/lib/ruby/site_ruby/2.1.0/rubygems/core_ext/kernel_require.rb:54:in `require'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/bin/fluentd:6:in `<top (required)>'
      /opt/td-agent/embedded/bin/fluentd:23:in `load'
      /opt/td-agent/embedded/bin/fluentd:23:in `<top (required)>'
      /usr/sbin/td-agent:7:in `load'
      /usr/sbin/td-agent:7:in `<main>'
  Thread #<Thread:0x007fce4f1910c0> status=sleep priority=0
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/output.rb:165:in `sleep'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/output.rb:165:in `wait'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/output.rb:165:in `cond_wait'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/output.rb:149:in `run'
  Thread #<Thread:0x007fce4f192880> status=sleep priority=0
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/cool.io-1.4.2/lib/cool.io/loop.rb:88:in `run_once'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/cool.io-1.4.2/lib/cool.io/loop.rb:88:in `run'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/plugin/out_forward.rb:185:in `run'
  Thread #<Thread:0x007fce4f18eb40> status=sleep priority=0
      /opt/td-agent/embedded/lib/ruby/2.1.0/net/http.rb:923:in `connect'
      /opt/td-agent/embedded/lib/ruby/2.1.0/net/http.rb:923:in `block in connect'
      /opt/td-agent/embedded/lib/ruby/2.1.0/timeout.rb:75:in `timeout'
      /opt/td-agent/embedded/lib/ruby/2.1.0/net/http.rb:923:in `connect'
      /opt/td-agent/embedded/lib/ruby/2.1.0/net/http.rb:863:in `do_start'
      /opt/td-agent/embedded/lib/ruby/2.1.0/net/http.rb:852:in `start'
      /opt/td-agent/embedded/lib/ruby/2.1.0/net/http.rb:1375:in `request'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/faraday-0.9.2/lib/faraday/adapter/net_http.rb:82:in `perform_request'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/faraday-0.9.2/lib/faraday/adapter/net_http.rb:40:in `block in call'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/faraday-0.9.2/lib/faraday/adapter/net_http.rb:87:in `with_net_http_connection'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/faraday-0.9.2/lib/faraday/adapter/net_http.rb:32:in `call'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/faraday-0.9.2/lib/faraday/rack_builder.rb:139:in `build_response'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/faraday-0.9.2/lib/faraday/connection.rb:377:in `run_request'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/faraday-0.9.2/lib/faraday/connection.rb:177:in `post'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/mackerel-client-0.1.0/lib/mackerel/client.rb:108:in `post_service_metrics'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluent-plugin-mackerel-0.1.3/lib/fluent/plugin/out_mackerel.rb:161:in `send'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluent-plugin-mackerel-0.1.3/lib/fluent/plugin/out_mackerel.rb:151:in `write'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/buffer.rb:345:in `write_chunk'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/buffer.rb:324:in `pop'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/output.rb:329:in `try_flush'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/output.rb:140:in `run'
  
  ...
  
    GC stat:
      count: 59808
      heap_used: 261
      heap_length: 261
      heap_increment: 0
      heap_live_slot: 105333
      heap_free_slot: 1061
      heap_final_slot: 0
      heap_swept_slot: 26253
      heap_eden_page_length: 261
      heap_tomb_page_length: 0
      total_allocated_object: 2536413815
      total_freed_object: 2536308482
      malloc_increase: 3756384
      malloc_limit: 16777216
      minor_gc_count: 58261
      major_gc_count: 1547
      remembered_shady_object: 2178
      remembered_shady_object_limit: 2276
      old_object: 62144
      old_object_limit: 112630
      oldmalloc_increase: 3800672
      oldmalloc_limit: 16777216
  Built-in objects:
   106,394: TOTAL
    47,172: T_STRING
    21,189: T_DATA
    16,574: T_ARRAY
     6,805: T_NODE
     3,221: T_OBJECT
     3,064: T_CLASS
     2,418: T_HASH
     1,910: T_FILE
     1,300: FREE
       736: T_ICLASS
       719: T_REGEXP
       701: T_STRUCT
       287: T_MATCH
       168: T_MODULE
        61: T_BIGNUM
        59: T_RATIONAL
         9: T_FLOAT
         1: T_COMPLEX
[watashi@example-host ~]$
```


#### よくわからんが読んで見る

```
  Thread #<Thread:0x007fce4f18f1a8> status=sleep priority=0
      /opt/td-agent/embedded/lib/ruby/2.1.0/net/http.rb:923:in `connect'
      /opt/td-agent/embedded/lib/ruby/2.1.0/net/http.rb:923:in `block in connect'
      /opt/td-agent/embedded/lib/ruby/2.1.0/timeout.rb:75:in `timeout'
      /opt/td-agent/embedded/lib/ruby/2.1.0/net/http.rb:923:in `connect'
      /opt/td-agent/embedded/lib/ruby/2.1.0/net/http.rb:863:in `do_start'
      /opt/td-agent/embedded/lib/ruby/2.1.0/net/http.rb:852:in `start'
      /opt/td-agent/embedded/lib/ruby/2.1.0/net/http.rb:1375:in `request'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/faraday-0.9.2/lib/faraday/adapter/net_http.rb:82:in `perform_request'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/faraday-0.9.2/lib/faraday/adapter/net_http.rb:40:in `block in call'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/faraday-0.9.2/lib/faraday/adapter/net_http.rb:87:in `with_net_http_connection'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/faraday-0.9.2/lib/faraday/adapter/net_http.rb:32:in `call'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/faraday-0.9.2/lib/faraday/rack_builder.rb:139:in `build_response'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/faraday-0.9.2/lib/faraday/connection.rb:377:in `run_request'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/faraday-0.9.2/lib/faraday/connection.rb:177:in `post'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/mackerel-client-0.1.0/lib/mackerel/client.rb:108:in `post_service_metrics'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluent-plugin-mackerel-0.1.3/lib/fluent/plugin/out_mackerel.rb:161:in `send'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluent-plugin-mackerel-0.1.3/lib/fluent/plugin/out_mackerel.rb:151:in `write'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/buffer.rb:345:in `write_chunk'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/buffer.rb:324:in `pop'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/output.rb:329:in `try_flush'
      /opt/td-agent/embedded/lib/ruby/gems/2.1.0/gems/fluentd-0.12.20/lib/fluent/output.rb:140:in `run'
```

`fluent-plugin-mackerel`と`faraday`という文字列が見える

### mackerel-client-rubyにPRを送る

[pull/24](https://github.com/mackerelio/mackerel-client-ruby/pull/24)のやりとりがそれ  

`faraday`に`timeout`のオプションがなかったので足した。


## 後処理

- 対象サーバで`mackerel-client-ruby`をバージョンアップ

```
[watashi@example-host ~]$
[watashi@example-host ~]$ sudo /opt/td-agent/embedded/bin/gem update mackerel-client
Updating installed gems
Updating mackerel-client
Fetching: mackerel-client-0.1.1.gem (100%)
Successfully installed mackerel-client-0.1.1
Parsing documentation for mackerel-client-0.1.1
Installing ri documentation for mackerel-client-0.1.1
Installing darkfish documentation for mackerel-client-0.1.1
Done installing documentation for mackerel-client after 0 seconds
Parsing documentation for mackerel-client-0.1.1
Done installing documentation for mackerel-client after 0 seconds
Gems updated: mackerel-client
[watashi@example-host ~]$
```

- 対象のプロセスを始末してデーモンを起動

```
[watashi@example-host ~]$ kill 7915
[watashi@example-host ~]$ ps auxwwwf | grep td-agent
td-agent  7779  0.0  0.3 241756 26836 ?        Sl   May27   0:00 /opt/td-agent/embedded/bin/ruby /usr/sbin/td-agent --log /var/log/td-agent/td-agent.log --use-v1-config --group td-agent --daemon /var/run/td-agent/td-agent.pid
td-agent  7915  0.3  3.7 838976 288956 ?       Sl   May27 225:44  \_ /opt/td-agent/embedded/bin/ruby /usr/sbin/td-agent --log /var/log/td-agent/td-agent.log --use-v1-config --group td-agent --daemon /var/run/td-agent/td-agent.pid
[watashi@example-host ~]$
[watashi@example-host ~]$ kill 7779
[watashi@example-host ~]$ ps auxwwwf | grep td-agent
td-agent  7779  0.0  0.3 241756 26836 ?        Sl   May27   0:00 /opt/td-agent/embedded/bin/ruby /usr/sbin/td-agent --log /var/log/td-agent/td-agent.log --use-v1-config --group td-agent --daemon /var/run/td-agent/td-agent.pid
td-agent  7915  0.3  3.7 838976 288956 ?       Sl   May27 225:44  \_ /opt/td-agent/embedded/bin/ruby /usr/sbin/td-agent --log /var/log/td-agent/td-agent.log --use-v1-config --group td-agent --daemon /var/run/td-agent/td-agent.pid
[watashi@example-host ~]$
[watashi@example-host ~]$ kill -9 7915
[watashi@example-host ~]$ kill -9 7779
[watashi@example-host ~]$ ps auxwwwf | grep td-agent
[watashi@example-host ~]$
[watashi@example-host ~]$
[watashi@example-host ~]$ sudo  service td-agent start
Starting td-agent:                                         [  OK  ]
[watashi@example-host ~]$
```

ログや`mackerel`などで問題なく出力がされているか確認する。  
  
サービスを利用させてもらっている側もこのように地味なところで貢献できるので  
何かあったら色々とやってみよう💪
