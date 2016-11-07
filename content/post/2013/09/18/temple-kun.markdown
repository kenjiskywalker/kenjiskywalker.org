---
layout: post
title: "golang on GAE で軽いものを取り敢えずつくる"
published: true
date: "2013-09-18T22:16:00+09:00"
comments: true


---

## [http://temple-kun.appspot.com/](http://temple-kun.appspot.com/)

IPアドレス返すだけのヤツ。  
  
元ネタはこれ。  
[http://ifconfig.me/](http://ifconfig.me/)  
  
本家のifconfig.meはUserAgent見て返す値変えてるんだけど取り敢えず。  
  
手順は  
[the Go Getting Started Guide / google app engine](https://developers.google.com/appengine/docs/go/gettingstarted/introduction)

ファイルのアップロード自体は  
[Python アプリケーションのアップロード、ダウンロード、管理 / Google App Engine](https://developers.google.com/appengine/docs/python/tools/uploadinganapp?hl=ja)  
に書いてあるように`appcfg.py update myapp/`でイケる。  
  
gitでもdeployできるけど  
[Using Git and Push-to-Deploy / Google App Engine](https://developers.google.com/appengine/docs/push-to-deploy)

```Request failed because the app binary was missing. This can generally be fixed by redeploying your app.```  
  
というようにエラーになってしまって上手く行かなかった。  
やり方が悪いのだと思う。この辺は改めて調べたい。  

{% gist 6609648 address-check.go %}    

{% gist 6609648 local-address-check.go %}    

`fprintf`とか`println`とか10年ぶりぐらいに見た。  
プログラミング初心者だけどすぐ動いてくれるので面白かった。

ドキュメントもシンプルに載ってて簡単に試せて有り難い。  
  
[http://golang.org/pkg/net/http/](http://golang.org/pkg/net/http/)

プログラミング面白いのでちまちま色々つくって行くの楽しい。  
