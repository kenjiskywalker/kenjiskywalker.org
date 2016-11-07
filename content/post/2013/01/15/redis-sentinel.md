---
layout: post
title: "Redis Sentinelを試す"
published: true
date: "2013-01-15T19:42:00+09:00"
comments: true


keywords: Redis,Sentinel,Redis Sentinel

---

某社では[RedisをKeepalivedでフェイルオーバーする構成案 / 酒日記 はてな支店](http://d.hatena.ne.jp/sfujiwara/20120802/1343880266)  
みたいな構成が使われているとか使われていないとかで、Sentinelはどうなのだろうか  
というお話がわいたので、カジュアルに試してみました。

参考：[Redis Sentinel Documentation](http://redis.io/topics/sentinel)

`6379 Port が Master`  
`6380 Port が 6379のSlave`  

上記内容のRedisのセットがあるとします。


```
[hoge@example ~]# 
[hoge@example ~]# redis-cli -p 6379 info | grep role -3
latest_fork_usec:340

# Replication
role:master
connected_slaves:1
slave0:127.0.0.1,6380,online

[hoge@example ~]# redis-cli -p 6380 info | grep role -3
latest_fork_usec:336

# Replication
role:slave
master_host:127.0.0.1
master_port:6379
master_link_status:up
[hoge@example ~]# 

```


`sentinel.conf`はソースファイルから拾ってくるのでも良いし  
参考サイトからコピペするでも良いかと。

```
[hoge@example ~]# cat /etc/sentinel.conf 
sentinel monitor mymaster 127.0.0.1 6379 1
sentinel down-after-milliseconds mymaster 10000
sentinel failover-timeout mymaster 50000
sentinel can-failover mymaster yes
sentinel parallel-syncs mymaster 1
[hoge@example ~]# 
[hoge@example ~]# 
[hoge@example ~]# redis-server /etc/sentinel.conf --sentinel
[8373] 15 Jan 19:44:27.071 * Max number of open files set to 10032
                _._                                                  
           _.-``__ ''-._                                             
      _.-``    `.  `_.  ''-._           Redis 2.6.8 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._                                   
 (    '      ,       .-`  | `,    )     Running in sentinel mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 26379
 |    `-._   `._    /     _.-'    |     PID: 8373
  `-._    `-._  `-./  _.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |           http://redis.io        
  `-._    `-._`-.__.-'_.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |                                  
  `-._    `-._`-.__.-'_.-'    _.-'                                   
      `-._    `-.__.-'    _.-'                                       
          `-._        _.-'                                           
              `-.__.-'                                               

[8373] 15 Jan 19:44:27.078 * +slave slave 127.0.0.1:6380 127.0.0.1 6380 @ mymaster 127.0.0.1 6379

 --- 動きました --
```

```
 ...

  ＿人人人人人人人人人＿
  ＞  Master突然の死  ＜
  ￣Y^Y^Y^Y^Y^Y^Y^Y￣

```

```
 ...

[8373] 15 Jan 19:45:41.854 # +sdown master mymaster 127.0.0.1 6379 6380 @ mymaster 127.0.0.1 6379
[8373] 15 Jan 19:45:41.854 # +odown master mymaster 127.0.0.1 6379 #quorum 1/1
[8373] 15 Jan 19:45:41.855 # +failover-triggered master mymaster 127.0.0.1 6379
[8373] 15 Jan 19:45:41.855 # +failover-state-wait-start master mymaster 127.0.0.1 6379 #starting in 6893 milliseconds

ログがゴニョゴニョ出てきて

[8373] 15 Jan 19:45:48.750 # +failover-state-select-slave master mymaster 127.0.0.1 6379
[8373] 15 Jan 19:45:48.851 # +selected-slave slave 127.0.0.1:6380 127.0.0.1 6380 @ mymaster 127.0.0.1 6379
[8373] 15 Jan 19:45:48.852 * +failover-state-send-slaveof-noone slave 127.0.0.1:6380 127.0.0.1 6380 @ mymaster 127.0.0.1 6379
[8373] 15 Jan 19:45:48.953 * +failover-state-wait-promotion slave 127.0.0.1:6380 127.0.0.1 6380 @ mymaster 127.0.0.1 6379
[8373] 15 Jan 19:45:48.954 # +promoted-slave slave 127.0.0.1:6380 127.0.0.1 6380 @ mymaster 127.0.0.1 6379
[8373] 15 Jan 19:45:48.954 # +failover-state-reconf-slaves master mymaster 127.0.0.1 6379
[8373] 15 Jan 19:45:49.054 # +failover-end master mymaster 127.0.0.1 6379
[8373] 15 Jan 19:45:49.054 # +switch-master mymaster 127.0.0.1 6379 127.0.0.1 6380

マスター変わったよーというログが出ていますね

```

Redisのレプリケーションの状況を確認

```
[hoge@example ~]# 
[hoge@example ~]# redis-cli -p 6379 info | grep role -3
Could not connect to Redis at 127.0.0.1:6379: Connection refused
[hoge@example ~]# 
[hoge@example ~]# redis-cli -p 6380 info | grep role -3
latest_fork_usec:336

# Replication
role:master
connected_slaves:0

# CPU
[hoge@example ~]# 
```

`6380 PortのRedis`がMasterになっていますね。  

とてもシンプルにfailoverが可能であることがわかりました。

> この設定だけでは`Master <=> Slave`間で障害が発生した場合など  
> 諸所問題点があるので、ちょっと工夫が必要。


その他ドキュメントを読んでて気付いたところ

 - `sentinel parallel-syncs hoge 1` hogeがMasterに切り替わった時にslave化する数。あんまり増やすとデータの同期取ったりすることに時間がかかるよとのこと。

 - `SDOWN(主体的ダウン検知)`、`ODOWN(客観的ダウン検知)`の2つのパターンがあり、それぞれの状態を観察しているのが面白い

基本的に1ページによくまとまっていて、`Sentinel Rule`を読むことで  
どのような状態になった時に、どうのような状態に遷移させる。  
判断基準としてはこれとこれを見ている。  

などなど、シンプルかつ丁寧に書かれており、とても読みやすい印象でした。
