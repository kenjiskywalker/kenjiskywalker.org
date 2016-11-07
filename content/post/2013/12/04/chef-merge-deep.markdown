---
layout: post
title: "Chefのnode[:hoge]をどうにかしたい"
published: true
date: "2013-12-04T14:26:00+09:00"
comments: true


---

2013年オワコンの代表格として名指しされているChefですが  
__nodes/hoge.json__で与えられた`node[:hoge]`の値を  
__roles/role.json__で値を追加したい場合があります。  
そのやり方として、オフィシャルにはディープマージという方法が載っていました。

[http://docs.opscode.com/essentials_node_object_deep_merge.html](http://docs.opscode.com/essentials_node_object_deep_merge.html)  
  
- nodes/hoge.json
```
{
  "run_list": [ "role[role_one]" ] 
}
```

- roles/role_one.json
```
{
  "name": "role_one",
  "description": "role one",
  "json_class": "Chef::Role",
  "override_attributes": {
    "hoge": [ "foo", "bar" ]
  },
  "default_attributes": {
  },
  "chef_type": "role",
  "run_list": [
    "role[role_two]"
  ]
}
```

- roles/role_two.json
```
{
  "name": "role_two",
  "description": "role two",
  "json_class": "Chef::Role",
  "override_attributes": {
    "hoge": [ "baz" ]
  },
  "default_attributes": {
  },
  "chef_type": "role",
  "run_list": [
    "recipe[hoge_recipe]"
  ]
}
```

- cookbooks/hoge_recipe/recipe/default.rb
```
node[:hoge].each do |h|
  p h
end
```

`role`で回せと。

ほかにも[@keita](https://twitter.com/keita)氏に教えてもらったのですが  
Key-Valueで渡せばいけるらしいです。  

[Arrays and Chef Attributes - Noah Kantrowitz](https://coderanger.net/2013/06/arrays-and-chef/)

- nodes/hoge.json
```
{
  "hoge": {
      "foo": true,
      "bar": true
  },
  "run_list": [ "role[role_one]" ] 
}
```

- roles/role_one.json
```
{
  "name": "role_one",
  "description": "role one",
  "json_class": "Chef::Role",
  "override_attributes": {
    "hoge": {
        "baz": true
    }
  },
  "default_attributes": {
  },
  "chef_type": "role",
  "run_list": [
    "recipe[hoge_recipe]"
  ]
}
```

- cookbooks/hoge_recipe/recipe/default.rb
```
node[:hoge].each do |k,v|
  p k
end
```

どちらも気持ち悪いので使いません。  
よさ気な方法あれば教えて下さい。  
  
Chef、Opscode社の経典みたいなcookbooksと  
何がどこに書かれているかよくわからないドキュメントをのぞけば  
2014年もよしなに使えるのではないかと思います。
