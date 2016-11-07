---
layout: post
title: "Chefで公開したくないJSONデータを暗号化するためにDataBagsを利用してみた記録"
published: true
date: "2013-05-20T18:44:00+09:00"
comments: true


keywords: chef,暗号化,data_bag
---

> ruby 1.8.7  
> chef 11.4.4  
> knife-solo_data_bag 0.3.2  

2013/05/20 現在

> knife-solo 0.2.0 では "knife solo data bag" は使えず  
> https://github.com/thbishop/knife-solo_data_bag こちらを利用

---

## 参考

- [About Data Bags — Chef Docs](http://docs.opscode.com/essentials_data_bags.html)
- [Encrypt a Data Bag — Chef Docs](http://docs.opscode.com/essentials_data_bags_encrypt.html)


## knife-solo_data_bagのインストール

```
# gem install knife-solo_data_bag 
# cd /root/chef/ ; pwd
```

## 暗号化用の鍵を用意

```
# openssl rand -base64 512 > encrypted_data_bag_secret
```

## 環境整備

```
# mkdir /root/chef/data_bags
# cat /root/.chef/knife.rb
cookbook_path '/root/chef/cookbooks'
data_bag_path '/root/chef/data_bags'
encrypted_data_bag_secret '/root/chef/encrypted_data_bag_secret'
#
```

のような感じでknifeの設定を整えます


## data_bagをつくる

```
#
# knife solo data bag create data_hoge bag_hoge --secret-file ./encrypted_data_bags_secret
ERROR: RuntimeError: Please set EDITOR environment variable
#
# export EDITOR=vim
#
# knife solo data bag create data_hoge bag_hoge --secret-file ./encrypted_data_bags_secret
{
    "id": "bag_hoge",
  "data": "bagbag"
}
# 
# cat /root/chef/data_bags/data_hoge/bag_hoge.json
{
  "data_bag": "data_hoge",
  "chef_type": "data_bag_item",
  "name": "data_bag_item_data_hoge_bag_hoge",
  "json_class": "Chef::DataBagItem",
  "raw_data": {
    "id": "bag_hoge",
    "data": {
      "iv": "++q0Yc6EHUu8bdAxb/Ekuw==\n",
      "version": 1,
      "encrypted_data": "ErOwQM7QzvSJavsHPQovjwmRk7egm6EOCvDz2cUMd0Y=\n",
      "cipher": "aes-256-cbc"
    }
  }
}#
#
# knife solo data bag show data_hoge bag_hoge
data: bagbag
id:   bag_hoge
#
```

`bag_hoge.json`の実ファイルを開いても中身は暗号化されている


## 秘密鍵が利用されているか確認

```
# cat /root/.chef/knife.rb
cookbook_path '/root/chef/cookbooks'
data_bag_path '/root/chef/data_bags'
# encrypted_data_bag_secret '/root/chef/encrypted_data_bag_secret' 

#
```

コメントアウトしてみる

```
aws_keys = Chef::EncryptedDataBagItem.load(, secret)
# knife solo data bag show data_hoge bag_hoge
data:
  cipher:         aes-256-cbc
  encrypted_data: ErOwQM7QzvSJavsHPQovjwmRk7egm6EOCvDz2cUMd0Y=

  iv:             ++q0Yc6EHUu8bdAxb/Ekuw==

  version:        1
id:   bag_hoge
#
```

復号化されない。秘密鍵が使われていることがわかる

## recipeから呼び出す

`solo.rb`

```
file_cache_path '/tmp/chef-solo'
cookbook_path   '/root/chef/cookbooks'
data_bag_path   '/root/chef/data_bags'
encrypted_data_bag_secret '/root/chef/encrypted_data_bag_secret'
```

`data_bag_path`と`encrypted_data_bag_secret`でファイルの位置をsoloに教える。

`/root/chef/cookbooks/data_bag_test/recipes/default.rb`
```
data_bag = Chef::EncryptedDataBagItem.load('data_hoge','bag_hoge')
hoge = data_bag['data']

p "data_bag is [#{hoge}]"
```

こんな感じのrecipeをつくる


`data_bag_test.json`

```
{
   "run_list": [
    "data_bag_test"
  ]
}
```

のようなテストJSONを作成し、chef-soloを走らせる

```
# chef-solo -j data_bag_test.json -c solo.rb
Starting Chef Client, version 11.4.4
Compiling Cookbooks...
"data_bag is [bagbag]"
Converging 0 resources
Chef Client finished, 0 resources updated
#
```

上記のようにdata_bagの値が取得できれば成功。  
秘密鍵をcookbooksとは別で管理することにより  
漏洩してほしくない情報を暗号化することが可能になる。
  
とても便利。


## 暗号化しないで保存するパターン (05/28 追記)

`--secret-file`鍵を指定しなければ暗号化はされない。


```
# knife solo data bag create data_hoge bag_hoge
#
# knife solo data bag show data_hoge bag_hoge
data: bagbag
id:   bag_hoge
#
# cat /root/chef/data_bags/data_hoge/bag_hoge.json
{"name":"data_bag_item_data_hoge_bag_hoge","data_bag":"data_hoge","chef_type":"data_bag_item","raw_data":{"id":"bag_hoge","data":"bagbag"},"json_class":"Chef::DataBagItem"}
#
```

### recipe
```
aws_keys = data_bag_item("data_hoge","bag_hoge")

p "data_bag is [#{hoge}]"
```

でいける





### あわせて読みたい

[アルパカchef日記３日目　data bagについて / またはユーザ管理クックブックなど -- アルパカDiary](http://d.hatena.ne.jp/toritori0318/20130516/1368722444)  
大変勉強になるエントリーだ

