---
layout: post
title: "fluentdでCloudWatchのELBのメトリクスをZABBIXに渡す"
published: true
date: "2013-03-21T17:05:00+09:00"
comments: true


keywords: CloudWatch fluend ELB ZABBIX
---

ELBのCloudWatchにあるメトリクスをZABBIXで取得するためにfluentdを利用しました。  
これでELBのアラートの設定もZABBIXで行えるので、通知の一元化が行えます。  
もちろんZABBIXでグラフにすることもできます。



[fluent-plugin-zabbix](https://rubygems.org/gems/fluent-plugin-zabbix)  
[fluent-plugin-cloudwatch](http://rubygems.org/gems/fluent-plugin-cloudwatch)
  
この2つのfluentdプラグインを使います。  
  

#### td-agent.conf

```
<source>
  type cloudwatch
  tag  cloudwatch
  aws_key_id  YOUR_AWS_KEY_ID
  aws_sec_key YOUR_AWS_SECRET/KE
  cw_endpoint monitoring.ap-northeast-1.amazonaws.com

  namespace AWS/ELB
  metric_name HealthyHostCount,HTTPCode_Backend_2XX,HTTPCode_Backend_3XX,HTTPCode_Backend_4XX,HTTPCode_Backend_5XX,HTTPCode_ELB_4XX,Latency,RequestCount,UnHealthyHostCount
  dimensions_name LoadBalancerName
  dimensions_value YOUR_ELB_NAME
</source>

<match cloudwatch>
  type copy
 <store>
  type             zabbix
  zabbix_server    ZABBIX SERVER IP
  host             [ZABBIXに設定するホスト名。なんでもいい(hoge-elb)]
  name_keys        HealthyHostCount, HTTPCode_Backend_2XX, HTTPCode_Backend_3XX, HTTPCode_Backend_4XX, HTTPCode_Backend_5XX, HTTPCode_ELB_4XX, Latency, RequestCount, UnHealthyHostCount
  add_key_prefix   cloudwatch
 </store>
</match>
```

#### ZABBIXの設定

ホスト名は  
`[ZABBIXに設定するホスト名。なんでもいい(hoge-elb)]`
で指定したものを。
  
![https://dl.dropbox.com/u/5390179/zabbix-cloudwatch.png](https://dl.dropbox.com/u/5390179/zabbix-cloudwatch.png)  
  
こんな感じでアイテムを設定します。

* キー：cloudwatch.HealthyHostCount
* データ型：整数とか浮動小数点型とか
* タイプ：ZABBIX Trapper


![https://dl.dropbox.com/u/5390179/zabbix-cloud-triger.png](https://dl.dropbox.com/u/5390179/zabbix-cloud-triger.png)  
  
トリガーはこんな感じで**UnHealthyHost**が0よりも大きければwarningを  
みたいな監視が行えるようになります。  
  
**Latency**や**RequestCount**なんかもグラフにできるので  
良い感じっぽいです。  
  
> 画像小さいのウケますね
