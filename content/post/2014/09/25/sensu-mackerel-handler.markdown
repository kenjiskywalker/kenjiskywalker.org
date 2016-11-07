---
layout: post
title: "sensuのmackerel用のmetrics handlerをつくった #mackerelio"
published: true
date: "2014-09-25T14:38:00+09:00"
comments: true


---

[Mackerel Meetup #2 Tokyo](http://mackerelio.connpass.com/event/8458/)に参加してきました。  

美味しいサバ料理頂いたりピザ頂いたりビール頂いたりして最高でした。  
個人的には監視はSensuかnagiosかに任せて、  
メトリクス周りをmackerelに任せたいなという構想があったりなかったりしています。  
  
mackerelがDataDogを超えて全世界で使われるようになったら  
面白そうですよね。  
  
個人的にほしい機能は監視の充実より先にメトリクス周りの整備をしてほしいです。  
  
@fujiwaraさんが、n分前と現在の差分データを取得できると良いとおっしゃっていて  
それあったら便利だな〜、と便乗していました(もちろんZabbixは可能です)。  
  
使うか使わないかはわかりませんが、Sensuのhandlerで  
mackerelを指定できるようプラグインを作成しました。  
  
hostの登録は別でしないといけませんが(plugin側で担保しても良いかも)  
既にSensuを利用している方は、こちらのhandlerを入れてもらえれば  
mackerelへmetricsを送信することが可能です。  
  
どうぞご利用ください。  
  
- [mackerel-metrics.rb](https://github.com/kenjiskywalker/sensu-community-plugins/blob/master/handlers/metrics/mackerel-metrics.rb)  
- [mackerel-metrics.json](https://github.com/kenjiskywalker/sensu-community-plugins/blob/master/handlers/metrics/mackerel-metrics.json)  
  
[pull requst](https://github.com/sensu/sensu-community-plugins/pull/777)中です。  
777番目なのでめでたいです。  
  
> はてな社の方へ  
> headerが雑なのでプロモーションも兼ねて編集して頂いた方がいいかもしれないです
