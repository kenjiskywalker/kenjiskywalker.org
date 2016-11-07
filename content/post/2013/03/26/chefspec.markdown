---
layout: post
title: "chefspecを利用したcookbookの動作テスト"
published: true
date: "2013-03-26T16:34:00+09:00"
comments: true


keywords: chef chefspec
---

> chefspec 1.0.0.rc1

Chefのcookbookのテストどうしたらいいんだろうって悩んでいたのですが  
chefspecが良さそうだったので試してみました。  
  
テストしたいことは  
  
- cookbookのrecipeに書いてあることが期待通り実行されるか
- ホスト名やプラットフォーム別のrecipeが期待通り実行されるか  
  
この2点です。  
  
下記のようなcookbookがあるとして  

`cookbook/yum/recipe/default.rb`  

```
template "/etc/yum.conf" do
  source "yum.conf.erb"
  owner  "root"
  mode   0644
end

file "/etc/yum/exclude.conf" do
  owner "root"
  mode  0644
  only_if { node[:platform_version].to_i == 5}
end

file "/etc/yum/installonlypkgs.conf" do
  owner "root"
  mode  0644
  only_if { node[:platform_version].to_i >= 6 }
end
```

`cookbook/yum/recipe/default.rb`  

```
[main]
cachedir=/var/cache/yum/$basearch/$releasever
keepcache=0
debuglevel=2
logfile=/var/log/yum.log
exactarch=1
obsoletes=1
gpgcheck=1
plugins=1
installonly_limit=3

#  This is the default, if you make this bigger yum won't see if the metadata
# is newer on the remote and so you'll "gain" the bandwidth of not having to
# download the new metadata and "pay" for it by yum not having correct
# information.
#  It is esp. important, to have correct metadata, for distributions like
# Fedora which don't keep old packages around. If you don't like this checking
# interupting your command line usage, it's much better to have something
# manually check the metadata once an hour (yum-updatesd will do this).
# metadata_expire=90m

# PUT YOUR REPOS HERE OR IN separate files named file.repo
# in /etc/yum.repos.d
<% if node[:platform_version].to_i == 5 %>
include=/etc/yum/exclude.conf
<% elsif node[:platform_version].to_i >= 6 %>
include=/etc/yum/installonlypkgs.conf
<% end %>
```

#### platform_versionが **5** のときは  
- */etc/yum/exclude.conf*をつくる
- */etc/yum.conf*に*"include=/etc/yum/exclude.conf"*の設定を追加

#### platform_versionが **6** のときは  
- */etc/yum/installonlypkgs.conf*をつくる
- */etc/yum.conf*に*"include=/etc/yum/installonlypkgs.conf"*の設定を追加  
  
という動作をテストします。

## Specファイルの書き方

```
$ gem install chefspec -v1.0.0.rc1
```

> v1.0.0じゃないとChef v11では動かなかった https://github.com/acrmp/chefspec/issues/109

使い方は[README](https://github.com/acrmp/chefspec/blob/master/README.md)を読めば大体わかります。  
Specファイルは `cookbook/*/spec/default_spec.rb` というファイルとして置きます。

`cookbook/yum/spec/default_spec.rb`

```
require 'chefspec'

# mock versions: https://github.com/customink/fauxhai/tree/master/lib/fauxhai/platforms/
# 5.8 or 6.2

describe 'yum::defaults platform version 5' do
  chef_run = ChefSpec::ChefRunner.new(platform:'centos', version:'5.8')
  chef_run.converge 'yum::default'
  it 'platform_version 5 yum include' do
    expect(chef_run).to create_file_with_content '/etc/yum.conf' , 'include=/etc/yum/exclude.conf'
  end
end

describe 'yum::defaults platform version 6' do
  chef_run = ChefSpec::ChefRunner.new(platform:'centos', version:'6.2')
  chef_run.converge 'yum::default'
  it 'platform_version 6 yum include' do
    expect(chef_run).to create_file_with_content '/etc/yum.conf' , 'include=/etc/yum/installonlypkgs.conf'
  end
end
```

chefspecはモックデータとしてfauxhaiのplatformsから、テストデータを引っ張ってきます。  
なので、CentOS系であれば  
  
- [https://github.com/customink/fauxhai/tree/master/lib/fauxhai/platforms/centos](https://github.com/customink/fauxhai/tree/master/lib/fauxhai/platforms/centos)  
  
この中から近いバージョンを選ぶ感じになるかと思います。  
  
このデータを利用することで  
プラットフォーム毎のテストを行うことができてだいぶ捗る印象があります。  

また、*create_file_with_content*で作成されるファイルと、その中にかかれてほしい文字列  
をテストすることができてなかなか良い感じっぽいです。  

## Rakeでテスト回す

`Rakefile`
```
task :default => [:chefspec]
begin
  require 'rspec/core/rake_task'
    RSpec::Core::RakeTask.new(:chefspec) do |spec|
      spec.pattern = 'cookbooks/*/spec/default_spec.rb'
      spec.rspec_opts = ['-cfs']
  end
rescue LoadError => e
end
```

Rakefileを上記な感じで記述して

```
$ rake
/Users/kenjiskywalker/.rbenv/versions/1.9.3-p392/bin/ruby -S rspec cookbooks/ntp/spec/default_spec.rb cookbooks/yum/spec/default_spec.rb -cfs
Compiling Cookbooks...
Compiling Cookbooks...

ntp::defaults
Compiling Cookbooks...
  should ntp package install
Compiling Cookbooks...
  should ntp.conf setting

yum::defaults platform version 5
  platform_version 5 yum include

yum::defaults platform version 6
  platform_version 6 yum include

Finished in 0.15855 seconds
```

みたいな感じで一発でテストを通すことができて便利っぽいです。  
以上、簡単なchefspec情報でした。
