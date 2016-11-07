---
layout: post
title: "MySQLのスレーブサーバを別サーバに移設する時に注意すること"
published: true
date: "2013-08-12T19:20:00+09:00"
comments: true


---

移設元のスレーブサーバのMySQLが停止できる場合  
移設先のスレーブサーバで

- CREATE DATABASEして   
- master.infoからreplユーザ作成して
- dumpファイルをバックアップサーバから持ってきて〜  

などの作業を行わなくても`SLAVE STOP`し  
MySQLを落とし変更が走らない状態にして  
MySQLのディレクトリを移設先に`rsync`で渡した方が手間も処理速度も遥かに速い。  
ただし、移設先でMySQLを起動して`SLAVE START`をすると

> Could not find target log during relay log initialization rellay.log

このようにrelay_logが見つからないよ。というエラーが発生する。

[16.2.2.1. The Slave Relay Log / MySQL 5.1 Reference Manual ](http://dev.mysql.com/doc/refman/5.1/en/slave-logs-relaylog.html)  
  
上記のようにホスト名が変わった場合にrelay_logのindexを修正する必要がある。  
これでレプリケーションが再開できるはずだ。  
  
オペレーションの手間も少なく効率的なので、移設元のスレーブサーバの  
MySQLが一時的に停止可能であれば、`rsync`でデータを持っていくのが  
効率的ではないでしょうか。  
  
移設先のサーバの利用可能なメモリ容量により  
`innodb_buffer_pool_size`などのチューニングが必要になるので  
設定ファイルなどは注意したい。  
  
また、スレーブサーバの増設などの場合は、`server-id`の変更漏れにも  
気を付けたい。取り敢えず移設でも`server-id`変えておくのが吉だ。
  
毎回同じようなハマり方をする自分の為への戒めも兼ねた戒メモ

## 追記(2013/08/13)

<blockquote class="twitter-tweet"><p>relay_logとか暗黙のデフォルトでホスト名が使われるところは明示的に指定しておいたほうがハマりにくいですよ / “MySQLのスレーブサーバを別サーバに移設する時に注意すること - さよならインターネット” <a href="http://t.co/IVPKvyxXWi">http://t.co/IVPKvyxXWi</a></p>&mdash; Ryuta Kamizono (@kamipo) <a href="https://twitter.com/kamipo/statuses/366906226359009280">August 12, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
  
  
kamipoさんのこちらの[my.cnf](https://github.com/kamipo/etcfiles/blob/master/etc/my.cnf#L57)が参考になる。  
kamipoさん、ありがとうございます。
