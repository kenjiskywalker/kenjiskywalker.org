---
layout: post
title: "Consul Clusterを手元に構築する簡単なスクリプトかいた"
published: true
date: "2014-09-08T21:01:00+09:00"
comments: true


---


## [https://github.com/kenjiskywalker/consul-test](https://github.com/kenjiskywalker/consul-test)

READMEのとおりですが  

```
Node    Address         Status  Type    Build  Protocol
node01  127.0.0.1:8301  alive   server  0.4.0  2
node02  127.0.0.2:8301  alive   server  0.4.0  2
node03  127.0.0.3:8301  alive   server  0.4.0  2
node04  127.0.0.4:8301  alive   client  0.4.0  2
```

上記構成のConsul Clusterを  
OS X上に簡単に作成できるスクリプトをつくりましたので  
よかったらご利用ください。  


### あわせてよみたい
  
[ConsulのDNSラウンドロビンの検証](http://blog.kenjiskywalker.org/blog/2014/06/06/consul-dns-round-robin/)  
