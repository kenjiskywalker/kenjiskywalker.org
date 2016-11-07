---
layout: post
title: "Redis Sentinelが動いていたらslaveof no oneしない"
published: true
date: "2013-03-20T02:36:00+09:00"
comments: true


---

> 色々とあれだったのでシンプルにキメうちにしました  
> thanks: @sawanoboly  
> update: 2013/03/22  

#### 環境
> Redis version 2.6.7

Redis Sentinelは 
 **Monitoring** 、 **Notification**  、**Automatic failover**  
の3つの機能があって、主に自動フェイルオーバ目的で利用する機会が多いと思うのですが  
その際に、手動で`slaveof no one`を打っちゃうことで予期しない状態になるので  
  
`slaveof no one`打つならRedis Sentinelを止めてからにしましょう。  

---

<del>事前情報</del>

<del>こんな感じでredis-sentinel.confが設定されているとします</del>  

<del> 構成: Master:1 <=> Slave:1  </del>

```
sentinel monitor check_one 192.168.2.100 6379 2
sentinel down-after-milliseconds check_one 5000
sentinel failover-timeout check_one 50000
sentinel can-failover check_one yes
sentinel parallel-syncs check_one 1

daemonize yes
pidfile /var/run/redis-sentinel.pid
loglevel notice
logfile /var/log/redis-sentinel.log
port 26379
```


<del> Redis Sentinelが動いているのに「slaveof no one」をかます</del>

<del>こわいですねー、Redis Sentinelさんが</del>  
<del>レプリケーションの状況理解できなくなってしまいますね。</del>  
<del>やるならRedis Sentinelは落としてやるべきですね。</del>  

<del>Redis Sentinelが動いているのに「slaveof host port」をかます</del>  

<del>こわいですねー、Redis Sentinelさんは</del>  
<del>そんなの無視して正しい状況に持って行こうとしますから</del>  
<del>やるならRedis Sentinelは落としてやるべきですね。</del>  
<del>永続的に設定を変更するなら、Redis Sentinelさんを落として</del>  
<del>設定を期待している内容にして起動し直すのが良いです</del>ね。

<del>## 対策？  </del>  
<del>などなど、Redis Sentinelさんが動いている状態での</del>  
<del>手動レプリケーション設定変更を行うと、色々と予期しないことが起こるので</del>  
<del>- Redis Sentinelが動いてる時に*slaveofなんとか*は発行しない</del>  
<del>- レプリケーションの設定を変えるならデータのバックアップをとっておく</del>  
<del>- レプリケーションの状態を変えるならRedis Sentinelは落としてから行う</del>  
<del>- レプリケーションの状態を変えるならRedis Sentinel側の設定を変えて落としてから行う</del>  
<del>など対策というか、ハウツーがあるかと思うのですが</del>  
<del>こういうオペミスっぽいのを未然に防ぐにはどうしたらいいですかねー</del>  
<del>って話をしてました。</del>  
<del>みなさんどうやってRedis使ってるんでしょう</del>  
<del></del>  
