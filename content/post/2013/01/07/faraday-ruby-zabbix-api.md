---
layout: post
title: "Faradayを利用してRubyでZabbix APIを叩く #zabbix_jp"
published: true
date: "2013-01-07T19:26:00+09:00"
comments: true


---

こんな感じでイケました。

{% gist 4473915 %}

参考：  
 - [Ruby の HTTP クライアントライブラリ Faraday が便利そう / mitukiii gist](https://gist.github.com/2775321)  
 - [Zabbix APIを使って値を取ってみる / ike-daiの日記](http://d.hatena.ne.jp/ike-dai/20110418/1303129550)  

アクセストークンは、ike-daiさんのブログを参考に`curl`コマンドで取得し、  
取得したアクセストークンを`auth`に入れています。
