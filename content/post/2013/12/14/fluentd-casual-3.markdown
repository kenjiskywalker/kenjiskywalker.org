---
layout: post
title: "Fluentd Casual Talks #3 でChefの話をしてきました #fluentdcasual"
published: true
date: "2013-12-14T01:46:00+09:00"
comments: true


---

## Fluentd Casual Talks #3 で話してきました
  
会場をご提供頂いたDeNAさん、主催者の@tagomorisさん、ありがとうございました。  
  
スライドはこちらです。  
  
<script async class="speakerdeck-embed" data-id="b9dcc770460d0131db724af7eb411f76" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>  
  
設定が増えてくると`td-agent.conf`自体が肥えてきます。  
その場合、`include config.d/hoge.conf`というように  
機能別に設定ファイルを分けることで、人間が管理できるようになります。  
  
設定ファイルについては、必要な設定だけを人間が行って  
ファイルの設置などについては、Chefに行ってもらうのが良いです。  
Chefの設定方法についてはスライドを見てもらうとなんとなくわかるかなと思います。  
ポイントは`include_recipe`を利用して、Chefのrecipe自体も分割するところです。
  

- chef/site-cookbook/td-agent/recipes/td-agent.conf

```
<source>
  type forward
  port 24224
</source>

include config.d/nginx.conf

<match **>
  type file
  path /tmp/unmatched
</match>
```

- chef/site-cookbook/td-agent/recipes/nginx.conf

```
template "/etc/td-agent/config.d/nginx.conf" do
  owner "root"
  mode  0644
  source "nginx.conf.erb"
end
```

- chef/site-cookbooks/td-agent/templates/default/nginx.conf.erb

```
<match nginx.access.**>
  type copy
  <store>
    type file_alternative
    time_slice_format %Y%m%d-%H
    path /var/log/aggregated/nginx/access
    output_data_type attr:message
    localtime
    output_include_time false
  </store>
</match>

...

```
このように分割します。`nginx.rb`や`rds.rb`には  
`nginx.conf`や`rds.conf`を生成するためのテンプレートが書かれています。  
スライド内の`s3cmd`の箇所を参照して頂ければ、どんな感じかわかると思います。
  
  
世界を前進させるスーパーな話も良いですが、増えすぎる設定ファイルを  
どう管理するか。みたいな話があっても良いのではないかと思い  
発表するに至りました。みなさんも良い管理方法などあれば  
是非とも教えて下さい。  
  
また、わからないことがあれば気軽に@kenjiskywalkerや、  
kenji at kenjiskywalker.orgに聞いて下さい。
  
fluentdのように設定が多岐に渡る場合などは  
Chefやpupet、Ansibleのような設定管理ツールを利用するのが良いですね。  
  
ライブリリース２本、ライブ感あってよかったですね。  
おつかれさまでした。
  
