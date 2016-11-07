---
layout: post
title: "CentOS 6.5でChefからSensuをインストールしようとするとRabbitMQでコケる回避策"
published: true
date: "2014-01-05T18:33:00+09:00"
comments: true


---

> date       : 2014/01/05  
> OS         : CentOS 6.5  
> Sensu      : sensu-0.12.3-1.x86_64  
> sensu-chef : 0.8.0  

=== (2014/01/06)追記 =======================

<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/kenjiskywalker">@kenjiskywalker</a> CentOS 6.4 → 6.5 にしたら出なくなった･･･うーむ</p>&mdash; Naoya Ito (@naoya_ito) <a href="https://twitter.com/naoya_ito/statuses/420100517943967744">January 6, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

ドラクエ氏によると、この解決策だと6.4は別のエラーがでるとのこと。


================================

<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/kenjiskywalker">@kenjiskywalker</a> centos?</p>&mdash; Naoya Ito (@naoya_ito) <a href="https://twitter.com/naoya_ito/statuses/419716838642032641">January 5, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>  

<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/kenjiskywalker">@kenjiskywalker</a> CentOS 6.4 の openssl のビルド設定が変わってて Erlang が crypto モジュールを読むところで落ちるです</p>&mdash; Naoya Ito (@naoya_ito) <a href="https://twitter.com/naoya_ito/statuses/419717299747037184">January 5, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>  

<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/naoya_ito">@naoya_ito</a> まさにこれですw どうにかできないかやってみます</p>&mdash; kenjiskywalker (@kenjiskywalker) <a href="https://twitter.com/kenjiskywalker/statuses/419717712474959872">January 5, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>  

<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/kenjiskywalker">@kenjiskywalker</a> うまくいったら教えてくださいｗ</p>&mdash; Naoya Ito (@naoya_ito) <a href="https://twitter.com/naoya_ito/statuses/419717651015823360">January 5, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>  

<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/voluntas">@voluntas</a> ありがとうございます。R16B02-0.1でいけるならerlang-solutionsでyumインストール時にバージョン指定すれば回避できるのかなと思ってChefでどうやるのか調べております</p>&mdash; kenjiskywalker (@kenjiskywalker) <a href="https://twitter.com/kenjiskywalker/statuses/419730565164580864">January 5, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>  

という感じでうまくいかなかったのでBKっぽいけど取り敢えず回避策を
  

## [https://github.com/sensu/sensu-chef](https://github.com/sensu/sensu-chef)  
  
このSensuのリポジトリは[opscode](http://community.opscode.com/cookbooks/sensu)に上がっているので  
knifeで取ってきます。他にも必要なrecipeを合わせて持ってこれるので便利です。

```
knife cookbook site vendor sensu -o cookbooks/
```

関係するrecipeがダウンロードされたことを確認してください。  
次にREADMEに書いてあるようにSSL証明書を作成します。

```
cd ./cookbooks/sensu/examples/ssl/
./ssl_certs.sh generate
knife data bag create sensu
knife data bag from file sensu ssl.json
```

などとSSLを作成しますが
knifeが上手く動かない場合は

```
mkdir ./data_bags/sensu
cp ./cookbooks/sensu/examples/ssl/ssl.json data_bags/sensu/
```

とすることで同じ結果を得られます。
次に`run_list`を作成します。

```
{
  "default_attributes": {
  },
  "override_attributes": {
  },
  "run_list": [
    "sensu",
    "sensu::redis",
    "sensu::rabbitmq"
  ]
}
```

この状態でChefを廻します。

```
Recipe: rabbitmq::default
  * service[rabbitmq-server] action restart
================================================================================
Error executing action `restart` on resource 'service[rabbitmq-server]'
================================================================================


Mixlib::ShellOut::ShellCommandFailed
------------------------------------
Expected process to exit with [0], but received '1'
---- Begin output of /sbin/service rabbitmq-server start ----
STDOUT: Starting rabbitmq-server: FAILED - check /var/log/rabbitmq/startup_{log, _err}
rabbitmq-server.
STDERR:
---- End output of /sbin/service rabbitmq-server start ----
Ran /sbin/service rabbitmq-server start returned 1


Resource Declaration:
---------------------
# In /root/chef-solo/cookbooks-3/rabbitmq/recipes/default.rb

106:   service node['rabbitmq']['service_name'] do
107:     action [:enable, :start]
108:   end
109:



Compiled Resource:
------------------
# Declared in /root/chef-solo/cookbooks-3/rabbitmq/recipes/default.rb:106:in `from_file'

service("rabbitmq-server") do
  action [:enable, :start]
  updated true
  supports {:restart=>false, :reload=>false, :status=>true}
  retries 0
  retry_delay 2
  service_name "rabbitmq-server"
  enabled true
  running true
  pattern "rabbitmq-server"
  startup_type :automatic
  cookbook_name :rabbitmq
  recipe_name "default"
end
```

と、このようにエラーになります。  

```
diff --git cookbooks/erlang/recipes/package.rb cookbooks/erlang/recipes/package.rb
index 19f9fce..6cec68f 100644
--- cookbooks/erlang/recipes/package.rb
+++ cookbooks/erlang/recipes/package.rb
@@ -43,5 +43,9 @@ when 'rhel'
     include_recipe 'yum-erlang_solutions'
   end

-  package 'erlang'
+  execute "yum install -y erlang-R16B02" do
+    user "root"
+    command "yum install -y erlang-R16B02"
+    not_if { File.exists? "/usr/bin/erl" }
+  end
 end
```

上記のようにバージョンを含めたパッケージの指定をすることで回避できました。

```
package 'erlang' do
  version "R16B02"
end
```

この方法でイケるかと思ったのですがそんなバージョンはない。とエラーになりました。  
以上、取り敢えずの回避策としてご利用下さい。
