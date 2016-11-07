---
layout: post
title: "#monitoringcasual vol3 に参加してきました"
published: true
date: "2013-03-09T15:44:00+09:00"
comments: true


keywords: fluent-plugin-cloudwatch-lite, fluent-plugin-rds-slowlog, monitoringcasual
---

## [Monitoring Casual Talk #3](http://www.zusaar.com/event/521056)に参加してきました。  

会場をご提供頂いた株式会社paperboy&co.さま  
@ume3_さん、@tnmtさん、@lamanotramaさん、ありがとうございました。  
  
会場へ向かう途中で、fujiwaraさんとsongmuさんが  
今日はmizzyさんいないからイケるかもしれないとか物騒なこと言ってて怖かったです。  
  
セルリアンタワー、曜日の夜にBARになるところがすごくて  
入り口にイケイケのおねーさんいたりして華やかや〜！！！ってなっていました。  
  
## 発表内容

[発表資料](http://www.slideshare.net/KenjiNaito/monitoringcasual-vol3)はこんな感じです。  
出発する30分前につくったのでそんなに大したものではないです。  
一枚目は 「*RDSのメトリクスをCloudWatchからfluentdへ、slow_logを添えて*」  
って書いてあります。  
フレンチっぽくしたかったんですけどただの読めない文字になってました。  
あと何枚目かに素敵な妖精が映ってるかもしれないですけど気のせいです。  

こんなんあったらいいなーって思ったら、素晴らしいプロダクトがたくさんあるので  
すぐにできて良いですね。という感じで5分ぐらいで話したんですけど  
みんな普通にライトニングじゃない時間トークしてて、  
何でか一番時間きっかりしてたのに手抜いた感じがしてて切なかったです。  
  

もにかじ中にお前ZABBIXのスクリーン消したろ？って社内IRCで声かけられて  
は〜申し訳ないです〜とか言いながらZABBIXのスクリーンつくりなおしてました。  
ZABBIXのスクリーン、業が深いので手作業でやらないようにしたいですね。  
  
## fluentdのプラグインをつくりました。  

[fluent-plugin-cloudwatch-lite](https://rubygems.org/gems/fluent-plugin-cloudwatch-lite)  
[fluent-plugin-rds-slowlog](https://rubygems.org/gems/fluent-plugin-rds-slowlog)  

**fluent-plugin-cloudwatch-lite** は、RDSのメトリクスをZABBIXで取得したかったので  
fluentdに120秒前と60秒前のデータを取ってくるものです。  
元々[fluent-plugin-cloudwatch](https://github.com/yunomu/fluent-plugin-cloudwatch)があって  
それを参考につくらせてもらいました。  
自分でThread書くとか多分無理だったので本当にありがたいです。  
  
**fluent-plugin-rds-slowlog** は、  
RDSのslow_logをファイルで保存したかったので書きました。  
最初シェルスクリプトでやってたんですけど、  
fujiwaraさんからfluentdでやれば？って言われて  
ほんとっスねってなって書きました。fluentdのplugin簡単に書けてすごいです。  
  
簡単に書けるからこそ、つくるならちゃんとしたものつくりたいなーって思いながら  
自信ないので、色々書いていくようになれば自信つくのかなーとか思ったりしてます。  
  
## もにかじ

もにかじ、次回ははてなさんらしいので超楽しみです。  
なんだったら鴨川でビールキメたりしたいですが、  
多分カミさんに物理的に抹消されるので厳しいです。  
  
もし次回参加できたら、次はこんなことで悩んでるんですけど  
みなさんどうしてます？みたいな感じで行きたいです。(前も言ってた気がする)  
  
## fujiwaraさん

[『いつもと違う』を検知したい](http://dl.dropbox.com/u/224433/monitoring_casual_3/index.html#1)  
  
ハンパない

## Perlのひとたち

Perl使ってる若者みんなスルーしてるけど、Perlおじさんたち  
disに対するアンサーソングみたいなのみんなキメてて怖かった。  
  
Twitter見たらまだ話してる人いて本当に物騒だなって思った。  

## ひとりじゃない

監視とかモニタリングとかってあんまりおもしろい話ないし  
すごい地道な作業が多いけど、みんなで集まって  
どうやって問題に対して解決してるかとか、  
こういう課題があるんだけどどうだとか、このツールどうだとか  
ワイワイ話したりするの楽しいなーって思いました。  
  
Twitter芸人として技術力ないけどコンテンツ力があるとか  
言われないように頑張って生きたい。  
  
頑張るのに疲れたらインターネットから解脱して仏像彫りたい
