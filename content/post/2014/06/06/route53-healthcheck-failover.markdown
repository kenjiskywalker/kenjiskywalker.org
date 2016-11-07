---
layout: post
title: "Route53を利用したフェイルオーバーシステムの作成"
published: true
date: "2014-06-06T00:04:00+09:00"
comments: true


---

AWSのRoute53サービスを利用し、冗長構成のあるシステムをつくる。

## TL;DR

同一のレコードをPrimaryとSecondaryで作成し  
Primary、SecondaryそれぞれでHealth Check to Associateを設定する。  
PrimaryのHealth Checkが失敗した場合、Secondaryに遷移する。  
SecondaryもダメだったらPrimaryに変わる。  
両方同じタイミングでダメになったらPrimaryのまま。


## 手順

### Health Checkの設定

##### 1. _Health Checks_ にてヘルスチェック対象のホスト・サービスを設定

### Health Checkを利用するレコードの作成

##### 2-1. _Hosted Zones_ にてフェイルオーバーを行いたいDNSを設定

##### 2-2. _Create Record Set_ にてレコードの作成(Primary)  
##### 2-3. _Routing Policy_ にて `Failover` を選択  
##### 2-4. _Failover Record Type_ にて _Primary_ を選択  
##### 2-5. _Associate with Health Check_ にて _Yes_ を選択  
##### 2-6. _Health Check to Associate_ にて 1. で作成したヘルスチェックを選択  
  
##### 2-7. _Create Record Set_ にてレコードの作成(Secondary)  
##### 2-8. _Routing Policy_ にて `Failover` を選択  
##### 2-9. _Failover Record Type_ にて _Secondary_ を選択  
##### 2-10. _Associate with Health Check_ にて _Yes_ を選択  
##### 2-11. _Health Check to Associate_ にて 1. で作成したヘルスチェックを選択  

２つの同じレコードを作成し、応答するレコードをそれぞれ  
Primary, Secondaryと指定することでフェイルオーバーする仕組み。

> www.example.com:80  
> 
>   => Primary
>    hoge01.example.com:80 (health check http://hoge01.example.com)  
> 
>   => Secondary
>    hoge02.example.com:80 (health check http://hoge02.example.com)

こんな構成で _http://www.example.com_ へのアクセスは通常だと  
_hoge01_ へアクセスが行くようになっていて、 _hoge01_ の  
レスポンスに異常があった場合に _hoge02_ へ行くようになる。  
  
試しに ヘルスチェックを _tcp:24224_ にしても問題なく認識したので  
fluentdの集約サーバを冗長構成にしておいて

> log.example.com:24224  
> 
>   => Primary
>    hoge01.example.com (health check tcp://hoge01.example.com:24224)  
> 
>   => Secondary
>    hoge02.example.com (health check tcp://hoge02.example.com:24224)

通常は _hoge01_ にて集約し、メンテナンスなど  
行いたい場合に _hoge01_ のfluentdを落としたら、自動的に  
レコードが切り替わり、 _hoge02_ の方へログが流れていくような構成が組めたりする。  
_hoge01_ のfluentd を立ち上げるとPrimaryが正常になったことが認識され  
レコードは元の _hoge01_ へ向き直る。  
  
SPOFをなるべくなくしていきたいので、この機能は役立ちそうだ。
