---
layout: post
title: "ConsulのDNSラウンドロビンの検証"
published: true
date: "2014-06-06T01:13:00+09:00"
comments: true


---

[Consul - hashicorp](http://www.hashicorp.com/blog/consul.html) を利用しDNS Failoverを検証した

> Consul v0.2.0

## TL;DR

hostnameやserviceなどでDNSを設定し  
DNSはnodeの死活監視によって動的に生まれ死んでいく。  
nodeとは別にserviceという概念があり、DNSラウンドロビンが行える


## loopback alias

@keita氏に教えてもらった  
[Mac OS X – Adding a loopback alias - THE DANGLING POINTER](http://astralbodi.es/2011/02/04/mac-os-x-adding-a-loopback-alias/)  
  
このloopbackのaliasが大変役に立った。

## nodeの用意

- 127.0.0.1(node01)
- 127.0.0.2(node02)
- 127.0.0.3(node03)

```
$ ifconfig lo0 alias 127.0.0.2
$ ifconfig lo0 alias 127.0.0.3
```

## 設定ファイルのディレクトリの用意

```
$ mkdir ./node01
$ mkdir ./node02
$ mkdir ./node03
```

## 設定ファイルの作成

- node01/config.json

Web UI用のデータは[ここ](http://www.consul.io/intro/getting-started/ui.html)からダウンロードして  
`ui_dir`にて指定してディレクトリへ配置する。

```
{
  "node_name": "node01",
  "data_dir": "./node01/",
  "bind_addr": "127.0.0.1",
  "client_addr": "127.0.0.1",
  "ui_dir": "./node01/",
  "domain": "foo",
  "bootstrap": true,
  "server": true
}
```

- node01/check.json

```
{
  "service": {
      "name": "echo",
      "tags": ["master"],
      "check": {
          "script": "echo 'hello'",
          "interval": "10s"
      }
  }
}
```


- node02/config.json

```
{
  "node_name": "node02",
  "data_dir": "./node02/",
  "bind_addr": "127.0.0.2",
  "client_addr": "127.0.0.2",
  "ui_dir": "./node02/",
  "domain": "foo",
  "bootstrap": true,
  "server": true
}
```

- node02/check.json

```
{
  "service": {
      "name": "echo",
      "tags": ["slave"],
      "check": {
          "script": "echo 'hello'",
          "interval": "10s"
      }
  }
}
```

- node03/config.json

```
{
  "node_name": "node03",
  "data_dir": "./node03/",
  "bind_addr": "127.0.0.3",
  "client_addr": "127.0.0.3",
  "ui_dir": "./node03/",
  "domain": "foo",
  "bootstrap": true,
  "server": true
}
```

- node03/check.json

```
{
  "service": {
      "name": "echo",
      "tags": ["slave"],
      "check": {
          "script": "echo 'hello'",
          "interval": "10s"
      }
  }
}
```


## nodeの起動

```
$ sudo consul agent -config-dir node01
$ sudo consul agent -config-dir node02
$ sudo consul agent -config-dir node03
```

## 名前解決をしてみる

- node01

```
$ dig @127.0.0.1 -p 8600 node01.node.foo. ANY

; <<>> DiG 9.8.3-P1 <<>> @127.0.0.1 -p 8600 node01.node.foo. ANY
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 3750
;; flags: qr aa rd; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 0
;; WARNING: recursion requested but not available

;; QUESTION SECTION:
;node01.node.foo.         IN      ANY

;; ANSWER SECTION:
node01.node.foo.  0       IN      A       127.0.0.1

;; Query time: 6 msec
;; SERVER: 127.0.0.1#8600(127.0.0.1)
;; WHEN: Fri Jun  6 01:36:37 2014
;; MSG SIZE  rcvd: 150

$
```

- node02

```
$ dig @127.0.0.1 -p 8600 node02.node.foo. ANY

; <<>> DiG 9.8.3-P1 <<>> @127.0.0.1 -p 8600 node02.node.foo. ANY
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 3750
;; flags: qr aa rd; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 0
;; WARNING: recursion requested but not available

;; QUESTION SECTION:
;node02.node.foo.         IN      ANY

;; ANSWER SECTION:
node02.node.foo.  0       IN      A       127.0.0.2

;; Query time: 6 msec
;; SERVER: 127.0.0.1#8600(127.0.0.1)
;; WHEN: Fri Jun  6 01:36:37 2014
;; MSG SIZE  rcvd: 150

$
```

- service

```
$ dig @127.0.0.1 -p 8600 echo.service.foo. ANY

; <<>> DiG 9.8.3-P1 <<>> @127.0.0.1 -p 8600 echo.service.foo. ANY
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 3750
;; flags: qr aa rd; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 0
;; WARNING: recursion requested but not available

;; QUESTION SECTION:
;echo.service.foo.         IN      ANY

;; ANSWER SECTION:
echo.service.foo.  0       IN      A       127.0.0.1
echo.service.foo.  0       IN      A       127.0.0.2
echo.service.foo.  0       IN      A       127.0.0.3

;; Query time: 6 msec
;; SERVER: 127.0.0.1#8600(127.0.0.1)
;; WHEN: Fri Jun  6 01:36:37 2014
;; MSG SIZE  rcvd: 150

$
```

- service(master)

```
$ dig @127.0.0.1 -p 8600 master.echo.service.foo. ANY

; <<>> DiG 9.8.3-P1 <<>> @127.0.0.1 -p 8600 master.echo.service.foo. ANY
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 3750
;; flags: qr aa rd; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 0
;; WARNING: recursion requested but not available

;; QUESTION SECTION:
;master.echo.service.foo.         IN      ANY

;; ANSWER SECTION:
master.echo.service.foo.  0       IN      A       127.0.0.1

;; Query time: 6 msec
;; SERVER: 127.0.0.1#8600(127.0.0.1)
;; WHEN: Fri Jun  6 01:36:37 2014
;; MSG SIZE  rcvd: 150

$
```

- service(slave)

```
$ dig @127.0.0.1 -p 8600 slave.echo.service.foo. ANY

; <<>> DiG 9.8.3-P1 <<>> @127.0.0.1 -p 8600 slave.echo.service.foo. ANY
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 3750
;; flags: qr aa rd; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 0
;; WARNING: recursion requested but not available

;; QUESTION SECTION:
;slave.echo.service.foo.         IN      ANY

;; ANSWER SECTION:
slave.echo.service.foo.  0       IN      A       127.0.0.2
slave.echo.service.foo.  0       IN      A       127.0.0.3

;; Query time: 6 msec
;; SERVER: 127.0.0.1#8600(127.0.0.1)
;; WHEN: Fri Jun  6 01:36:37 2014
;; MSG SIZE  rcvd: 150

$
```


## 機能毎のメモ

- bootstrapは最初の1台
- serverは3~5台ぐらいあったらいい
- nodeの名前は各nodeで設定される
- serviceは複数設定が可能。DNS Round Robinが行える
- _tag_ を設定することでサブドメインが利用可能になる
- 不要なホスト消す (curl -H "Content-Type: application/json" -d '{"Datacenter": "DATACENTER", "Node": "NODENAME"}' http://localhost:8500/v1/catalog/deregister)


以上、メモになります。
