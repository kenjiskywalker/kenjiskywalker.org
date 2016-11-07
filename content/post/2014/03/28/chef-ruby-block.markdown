---
layout: post
title: "Chefのruby_blockを利用してファイル更新時に条件によってログを出力する"
published: true
date: "2014-03-28T01:59:00+09:00"
comments: true


---

Chefには冪等性という特徴がありますが、実際の運用では  
ミドルウェアの設定の更新はしたいが、ミドルウェアの再起動までは  
自分の手で確認したい。という条件もあるかと思います。  
  

- 設定ファイルは常に更新しても良い
- 設定ファイルが更新された時だけミドルウェアを起動したい
- 設定ファイルが更新された時にミドルウェアが起動済みであればログに出力

上記条件を満たすために実施した内容について共有します。  

- chef/site-cookbooks/apache/recipes/default.rb

```
template "/etc/httpd/conf/httpd.conf" do
  source "httpd.conf.erb"
  owner  "www"
  mode   0644
  notifies :run, "ruby_block[warn]", :immediately
end

ruby_block "warn" do
  block do

    # httpdが起動中であればログ出力
    unless `pgrep httpd` == ""
      print <<"EOS"

\e[33m===================================================================
recipe:apache

apacheが起動中です。
新しい設定を反映させるためにはapahceを再起動してください。
===================================================================\e[0m
EOS
    end
  end
  action :nothing
  notifies :start, "service[httpd]"
end

service "httpd" do
  action :enable
end

```

1. `/etc/httpd/conf/httpd.conf` が更新される
2. `notifies :run, "ruby_block[warn]"`で`ruby_block`を実行
3. `ruby_block`内でミドルウェアが起動中かどうかRubyのコードで条件分岐
4. 起動中であればログを出力
5. `ruby_block`で`notifies :start, "service[httpd]"`を実行、ミドルウェアの起動を行う

`ruby_block`は実行順序が最後になるというChefの設計上、  
`notifies :start, "service[httpd]"`という方法を選択しました。  
  
もう少しマシな方法があれば是非とも教えてください。  
Chefは何か込み入ったことをしようとすると色々と工夫しないといけないのが難点ですね。
