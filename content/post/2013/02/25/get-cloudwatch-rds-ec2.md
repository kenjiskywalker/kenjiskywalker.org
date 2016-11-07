---
layout: post
title: "RDSの負荷状況を知りたかったのでCludWatchのAPIを叩くために書いた簡単なRubyスクリプト"
published: true
date: "2013-02-25T01:10:00+09:00"
comments: true


---

CloudWatchのAPI、プログラミング初心者にとって鬼門っぽい。  

{% gist 5024321 get_cloudwatch_rds.rb %}  

こんな感じで適当に叩いたら良い感じに取ってきてくれます。  
デフォルトの*metirc_name*パターンはコメントアウトに書いてます。  
  
start_timeとかperiodいじると返ってくるデータパターンが変わってくるので  
色々遊んでみてください。  
  
ついでにEC2のデータもとってくれるようなの書いてみたんですが  
デフォルトで手に入るメトリクス少ないので  
CloudWatchでデータ取るなら自分でメトリクスつくらないとダメですね。

{% gist 5024321 get_cloudwatch_ec2.rb %}  

Enjoy CloudWatch API!
