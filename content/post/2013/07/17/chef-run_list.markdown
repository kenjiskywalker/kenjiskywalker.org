---
layout: post
title: "chefの中身読んで、外部からrun_listを利用する"
published: true
date: "2013-07-17T00:29:00+09:00"
comments: true


---

run_listを渡してるところを探した。  
といってもほとんど[@soh335](https://twitter.com/soh335)が教えてくれた。さすが一流エンジニアだ。

`/chef/lib/chef/run_list.rb`

```
def expansion_for_data_source(environment, data_source, opts={})
  case data_source.to_s
  when 'disk'
    RunListExpansionFromDisk.new(environment, @run_list_items)
  when 'server'
    RunListExpansionFromAPI.new(environment, @run_list_items, opts[:rest])
  end
end
```

ここが怪しかった。


`/chef/spec/unit/run_list_spec.rb`

ここ見たら


```
    describe "from disk" do
      it "should load the role from disk" do
        Chef::Role.should_receive(:from_disk).with("stubby")
        @run_list.expand("_default", "disk")
      end

      it "should log a helpful error if the role is not available" do
        Chef::Role.stub!(:from_disk).and_raise(Chef::Exceptions::RoleNotFound)
        Chef::Log.should_receive(:error).with("Role stubby (included by 'top level') is in the runlist but does not exist. Skipping expand.")
        @run_list.expand("_default", "disk")
      end
    end
```

こんなん書いてあった。



```
#!/usr/bin/env ruby

require 'rubygems'
require 'pp'
require 'json'
require 'chef/run_list'

json_file = "./json/yoshimasa.json"

host_config = JSON.parse(File.read(json_file))

Chef::Config[:cookbook_path] = '/root/chef/cookbook/'
Chef::Config[:role_path] = '/root/chef/json/'

run_list = Chef::RunList.new("recipe[nginx]", "role[hoge]")

p run_list
# #<Chef::RunList:0x7f6fb8732510 @run_list_items=[#<Chef::RunList::RunListItem:0x7f6fb87323d0 @type=:recipe, @version=nil, @name="nginx">, #<Chef::RunList::RunListItem:0x7f6fb87323a8 @type=:role, @version=nil, @name="hoge">]>

pp run_list.expand("_default", "disk")
# #<Chef::RunList::RunListExpansionFromDisk:0x7f6fb8732100
#  @applied_roles={"hage"=>true, "hoge"=>true},
#  @default_attrs={},
#  @environment="_default",
#  @missing_roles_with_including_role=[],
#  @override_attrs={},
#  @recipes=["nginx", "postfix", "yum"],
#  @run_list_items=[],
#  @run_list_trace=
#   {"role[hoge]"=>["role[hage]", "recipe[postfix]", "recipe[yum]"],
#    "top level"=>["recipe[nginx]", "role[hoge]"]},
#  @source=nil>

p run_list.expand("_default", "disk").recipes
# ["nginx", "postfix", "yum"]
```

こんな感じでrun_listを読める。何が便利かっていうと

```
{
  "run_list": [
    "role[hage]"
  ]
}
```

```
{
  "run_list": [
    "recipe[postfix]", "recipe[yum]"
  ]
}
```

```
run_list = Chef::RunList.new("recipe[nginx]", "role[hoge]")

...
p run_list.expand("_default", "disk").recipes
# ["nginx", "postfix", "yum"]
```

という感じにroleの中のrun_listを読み込んでrecipesに突っ込んでくれる。  


