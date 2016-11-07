---
layout: post
title: "Consulでnodeの増減時に特定のスクリプトを実行させる"
published: true
date: "2014-09-09T22:21:00+09:00"
comments: true


---


## TL;DR

ConsulでSerfのEvent Handlerのようなものを試したメモ

## main

Consulの[0.4](https://www.hashicorp.com/blog/consul-0-4.html)から`Watches`という機能が追加されて  
Serfのevent handlerのようなことができるようになった。  

昨日つくった[consul-test](https://github.com/kenjiskywalker/consul-test)に  


- node01/config.json

```
{
  "node_name": "node01",
  "data_dir": "./node01/",
  "bind_addr": "127.0.0.1",
  "client_addr": "127.0.0.1",
  "ui_dir": "./dist/",
  "watches": [
    {
      "type": "nodes",
      "handler": "./node01/hosts_update.rb"
    }
  ]
}
```

watchesの設定を追加してみた。  
  
`hosts_update.rb`でやっていることはシンプルで  
nodesに変化があった場合に、標準入力でnodesの情報を取得し、  
同ディレクトリに`_hosts`ファイルを生成して、  
nodeの名前とそのAddressを  
hostsファイルに似せて出力するようにしている。  
  
> Consulには`SERF_EVENT`のような  
> 管理しているnodeの変化の状態をSTDINで受け取る方法はないのだろうか  

## 雑談

このような簡単なスクリプトはGoで書いてもいいかもしれないけど  
バイナリだけ置いてあるような状態の時に  
_作成者を全面的に信用する_みたいな部活っぽい対応になりそう。  
簡易スクリプトをGoで書いたらバイナリとそのソースファイルを  
同ディレクトリに置いておくとかが良いんだろうか。
