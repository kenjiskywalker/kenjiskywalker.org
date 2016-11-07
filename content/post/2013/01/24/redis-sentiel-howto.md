---
layout: post
title: "Redis Sentinelを動かしてみた"
published: true
date: "2013-01-24T16:13:00+09:00"
comments: true


keywords: Redis, Redis Sentinel

---

以前、[Redis Sentinelを試す](http://blog.kenjiskywalker.org/blog/2013/01/15/redis-sentinel/)というエントリーを書きましたが  
もう少し入り込んで検証してみた。  


殴り書きの域を出ていないので適時アップデートしていきたい。

## 検証環境

- DATE: 2013/01/25
- CentOS 6.3
- Redis 2.6.9(remi)

## ドキュメント

[http://redis.io/topics/sentinel](http://redis.io/topics/sentinel)

こちらを参考に行います。

## Sentinelの設定、および起動方法

```
$ /usr/local/bin/redis-server /etc/sentinel.conf --sentinel
[28498] 25 Jan 01:28:24.447 * Max number of open files set to 10032
                _._                                                  
           _.-``__ ''-._                                             
      _.-``    `.  `_.  ''-._           Redis 2.6.9 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._                                   
 (    '      ,       .-`  | `,    )     Running in sentinel mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 26379
 |    `-._   `._    /     _.-'    |     PID: 28498
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

[28498] 25 Jan 01:28:24.451 * +slave slave 192.168.2.102:6379 192.168.2.102 6379 @ mymaster 192.168.2.101 6379
[28498] 25 Jan 01:28:25.358 * +sentinel sentinel 192.168.2.101:26379 192.168.2.101 26379 @ mymaster 192.168.2.101 6379
```

こんな感じで起動します。

#### 設定ファイル

参考: [http://download.redis.io/redis-stable/sentinel.conf](http://download.redis.io/redis-stable/sentinel.conf)

```
sentinel monitor mymaster 127.0.0.1 6379 2
sentinel down-after-milliseconds mymaster 60000
sentinel failover-timeout mymaster 900000
sentinel can-failover mymaster yes
sentinel parallel-syncs mymaster 1
```

オフィシャルの設定ファイルを参考に。


#### 設定の意味

- `sentinel monitor <master-name> <ip> <redis-port> <quorum>`

この`<quorum>`は*Redis-Sentinelの数*を指します。  
Redis-Sentinelは、他のRedis-Sentinelが接続してきた場合に  
相互に理解する働きがあります。  
この機能によって*Split-brain-syndrome*を防ぐことが可能です。


#### Redisのレプリケーションが正常に行えている状態
![正常](https://dl.dropbox.com/u/5390179/Redis1.png)


#### Redisのレプリケーションの回線に障害が発生した場合
![突然の](https://dl.dropbox.com/u/5390179/Redis2.png)

上記のように、レプリケーションの経路に異常が発生した場合  
*Split-brain-syndrome*が起こり

![スプリットブレイン](https://dl.dropbox.com/u/5390179/Redis3.png)

レプリケーション情報は保てなくなり、お互いがMasterと認識してしまう問題があります。  

上記のような状況を避ける為に`<quorum>`の設定があります。  
このquorumの値は、***監視しているRedis-Sentinelの数***を表しています。  

上記のようにレプリケーションの経路に異常があった場合であっても  
`<quorum>`で設定した数のSentinelが異常を検知して初めてフェイルオーバーが始まります。  
SentinelはSentinel同士で理解し合う機能が搭載されているんですね。  
人間にもそんな機能があったら争いとかなくなりますかね。  

#### Redis-Sentinelの連絡が行えなくなり、Split-brain-syndromeは起こらない
![スプリットブレイン](https://dl.dropbox.com/u/5390179/Redis4.png)

ということで、`<quorum>`を2台以上設定することで、  
予期しないフェイルオーバーを予防することが可能です。

- `sentinel down-after-milliseconds mymaster 60000`

SentinelがDOWNを検知してからのフェイルオーバーを始めるまでのアイドル時間。
> DOWNと認める条件は[ドキュメント](http://redis.io/topics/sentinel)を参照。  
> *ODOWN*と*SDOWN*についてももう少し書きたい。  


検証時では *5000milliseconds* ぐらいが問題なく動作した。  
スペックや環境によってはもっとストイックな設定が可能。

なお、実際にMasterが切り替わるまで *5~15秒* の間でランダムな待ち時間が発生する。

> Sentinel Rule #14: A Sentinel detects a failover as an Observer
> (that is, the Sentinel just follows the failover generating the appropriate events in the log file and Pub/Sub interface,
>  but without actively reconfiguring instances) if the following conditions are true at the same time: * There is no failover already in progress.
> * A slave instance of the monitored master turned into a master. 
> However the failover will NOT be sensed as started if the slave instance turns into a master and at the same time the runid has changed from the previous one.
> This means the instance turned into a master because of a restart, and is not a valid condition to consider it a slave election.

> Sentinel Rule #15: A Sentinel starting a failover as leader does not immediately starts it.
> It enters a state called wait-start, that lasts a random amount of time between 5 seconds and 15 seconds.
> During this time Sentinel Rule #14 still applies: if a valid slave promotion is detected the failover as leader is aborted and the failover as observer is detected.

詳細は[ドキュメント](http://redis.io/topics/sentinel)の *Sentinel Rule #14,#15* を参照。

なので、フェイルオーバーが開始されるタイミングは  
 ***down-after-milliseconds + 5~15秒*** の時間になります。  


- `sentinel failover-timeout mymaster 900000`

フェイルオーバーを開始してから、レスポンスが返ってくるまでの  
待ち時間。詳細はやはりドキュメントを読んでほしい。  

> 検証時に "10 milliseconds" などストイックな設定を行なってみたが
> タイムアウトに引っかかり、レプリケーションが開始することはなかった...
> こちらもやはり "5000 milliseconds" ぐらいが安全であった

- `sentinel can-failover mymaster yes`

*mymaster*のダウン時に、フェイルオーバーを実行するか否かの設定。  


- `sentinel parallel-syncs mymaster 1`

フェイルオーバーが実行された後、新しいマスターを  
使用するように並列で再構成することができるスレーブの数の指定。

Slaveサーバが多く、この設定数が低いほど、  
フェイルオーバーの処理に時間がかかるとのこと。  
(未検証)


## おまけ：レプリケーションの構築手順

### Slave(192.168.2.102)

```
$ echo "slaveof 192.168.2.101 6379" | redis-cli -h 192.168.2.102
OK
$
$ redis-cli -h 192.168.2.102 info | grep -E 'mas|sla'
role:slave
master_host:192.168.2.101
master_port:6379
master_link_status:up
master_last_io_seconds_ago:5
master_sync_in_progress:0
slave_priority:100
slave_read_only:1
connected_slaves:0
$
```

### Master(192.168.2.101)

```
$ redis-cli -h 192.168.2.101 info | grep -E 'mas|sla'
role:master
connected_slaves:1
slave0:192.168.2.102,6379,online
$
```

### レプリケーションの情報

- `master_host:192.168.2.101`  
MasterのIPアドレス情報

- `master_port:6379`  
MasterのPort番号情報

- `master_link_status:up`  
Masterの状態の情報

- `master_last_io_seconds_ago`  
Slaveは10秒間隔でMasterへ*PING*を送信している。  
その"正常な"データを受信してからの経過時間の情報  

`monitor`コマンドで確認することができる。

```
$ redis-cli -h 192.168.2.102 monitor
OK
1359037270.075903 [0 192.168.2.101:6379] "PING"
1359037280.274001 [0 192.168.2.101:6379] "PING"
1359037290.464774 [0 192.168.2.101:6379] "PING"
```

- `master_sync_in_progress`  
Masterからデータを受信状況(SYNC)の情報  
SYNC中であれば *1* のフラグが立ち、状況の詳細が表示される。  

> 詳細はこちら : [INFO / Redis](http://redis.io/commands/info)


#### Masterが落ちていた場合の状態

```
master_link_status:down
master_last_io_seconds_ago:-1
master_sync_in_progress:0
master_link_down_since_seconds:N
```

*PING*の間隔が10秒間隔なので、疎通チェックも10秒間隔かと思うが  
そうではない(もう少し調べる)。

## おまけのおまけ

#### SlaveのSlaveも設定可能

`101.slave(Master) <= 102.6379(Slave) <= 102.6380(Slave)`

```
$ redis-cli -h 192.168.2.102 info | grep -E 'mas|sla'
role:slave
master_host:192.168.2.101
master_port:6379
master_link_status:up
master_last_io_seconds_ago:7
master_sync_in_progress:0
slave_priority:100
slave_read_only:1
connected_slaves:1
slave0:192.168.2.102,6380,online
$
```

> また、MasterとSlaveの接続が切れた場合も  
> Slave <=> Slaveの同期は停止する。(検証済み)


master_last_io_seconds_ago が Sentinel立ち上げる事に間隔が短かくなる  
3台上げたらほとんど1秒間隔になった。


## ということで

Sentinel、よく考えられているなという印象です。  
以上、この情報が何かのお役に立てれば幸いです。  

> This HOWTO is a work in progress, more information will be added in the near future.  

[https://github.com/antirez/redis-doc/blob/master/topics/sentinel.md](https://github.com/antirez/redis-doc/blob/master/topics/sentinel.md)

ということで、活発的に開発が行われているので  
適時チェックするのが良さそうですね。
