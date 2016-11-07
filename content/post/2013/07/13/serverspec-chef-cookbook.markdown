---
layout: post
title: "testing #chef cookbook by #serverspec #devops"
published: true
date: "2013-07-13T13:04:00+09:00"
comments: true


keywords: serverspec chef cookbook test
---

serverspec use chef json file and cookbooks.  
serverspec take run_list of `host.json`,  
serverspec do test each `cookbook_name/spec/any_test_spec.rb`.  

---

# tools

- [serverspec](http://serverspec.org/)
- [chef](http://www.opscode.com/chef/)

The configurations, please read at each document.

---

# howto

- ## chef cookbooks
 `/root/chef/cookbooks/{foo}/recipes/default.rb`
 `/root/chef/cookbooks/{bar}/recipes/default.rb`  
 ...

- ## serverspec file
 `/root/Rakefile`  
 `/root/spec/spec_helper.rb`  
 `/root/spec/{host_a}/host_a_mysql_spec.rb`   # host a specific test
 `/root/spec/{host_a}/host_a_redis_spec.rb`   # host a specific test
 `/root/spec/{host_b}/host_b_redis_spec.rb`   # host b specific test

- ## test file
 `/root/chef/cookbooks/{foo}/spec/default_spec.rb`  
 `/root/chef/cookbooks/{bar}/spec/default_spec.rb`  

 exp)  
 `/root/chef/cookbooks/redis/spec/setting_spec.rb`  
 `/root/chef/cookbooks/redis/spec/process_spec.rb`  

## `spec_helper.rb`

[Reference](http://serverspec.org/advanced_tips.html)

{% gist 6118553 spec_helper.rb %}

## `Rakefile`

{% gist 6118553 Rakefile %}

this Rakefile read `/root/chef/json/*.json` and `/root/chef/spec/host_name/*_spec.rb`

Please match it with your environment.

```
json_files = Dir::glob("./json/*.json")
 
Chef::Config[:cookbook_path] = './cookbook/'
Chef::Config[:role_path]     = './json/'
```
  
serverspec tests it look run_list of `host.json`

exp

`/root/chef/cookbooks/postfix/spec/default_spec.rb`

```
require "/root/chef/spec/spec_helper"

describe package('postfix') do
    it { should be_installed }
end

describe service('postfix') do
    it { should be_enabled }
    it { should be_running }
end

describe port(25) do
    it { should be_listening }
end

# log file
describe file('/var/log/maillog') do
    it { should be_file }
end

describe file('/etc/postfix/main.cf') do
    it { should be_file }
end

describe file('/etc/postfix/master.cf') do
    it { should be_file }
end
```

![http://gifzo.net/BIpiApSbg1E.gif](http://gifzo.net/BIpiApSbg1E.gif)

---

英語でちゃんと書こうと思ったけど  
取り敢えず出してあとでブラッシュアップする感じにしようと思った。  
`Rakefile`いじくるだけで`chef`の`host.json`のrun_list見て  
そのcookbookのspecディレクトリ見てテスト回してくれる。  
roleとかも考慮されてるし、一括で入れられないテストについては  
`/root/chef/spec/hostname/hoge_spec.rb`に入れればよしなに読み込んでくれる。  
便利っぽい。  
  
便利アピール海外にもしようと思ったら全然英語書けなくて頑張ろうって思った
