---
layout: post
title: "serverspecでchefのjsonを読み込む"
published: true
date: "2013-07-31T09:48:00+09:00"
comments: true


---

> 2013/12/25 update  
  
[Testing #chef Cookbook by #serverspec #devops](http://blog.kenjiskywalker.org/blog/2013/07/13/serverspec-chef-cookbook/)の続きみたいなものですが  
Chefのjsonファイルでフラグ立てたりしてると、そのフラグによって  
テスト対象が変化する場合があるかと思います。  
その場合、[serverspec](http://serverspec.org/)にはpropertyの機能があるのでそれを利用します。  

## spec/spec_helper.rb

{% gist 6118553 spec_helper.rb %}

`set_property`の項目を追加します。

## nodes/host.json

{% gist 6118553 nodes_host.json %}

こんな感じでこのMySQLはSlaveですみたいなフラグがあって

## cookbooks/mysql/templates/default/my.cnf.erb

{% gist 6118553 cookbooks_mysql_templates_default_my.cnf.erb %}

こんなテンプレートがあったら

## cookbooks/mysql/spec/is_slave_spec.rb

{% gist 6118553 cookbooks_mysql_spec_is_slave_spec.rb %}

このように`property["mysql"]["is_slave"]`として値を利用することができます。

> specファイル、`if ~ end`で囲ってるのがモサいので、良案をお待ちしております
