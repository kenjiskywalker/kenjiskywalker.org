---
layout: post
title: "pecoを利用してAWSのインスタンスを取得する"
published: true
date: "2014-06-18T12:19:00+09:00"
comments: true


---

## [peco](https://github.com/lestrrat/peco) を利用してAWSのEC2に簡単ログイン  
  
zsh、全然調べてなくて30分ぐらいで適当に書いたヤツです。

### TL;DR

zsh使っててaws-cli使っていてshellscriptを利用できるなら  
aws-cliを利用してnameとpublic dnsを紐付けてpecoで絞り込むだけのもの

### 設定

- shellscriptを起きます(get-ec2-list.sh)

```
#!/bin/bash

instances=$(aws ec2 describe-instances \
    --filters 'Name=instance-state-name,Values=running' \
    --query 'Reservations[].Instances[?PublicDnsName!=`null`].[Tags[*][?Key==`Name`].Value[],PublicDnsName]' \
    --output text)

for item in ${instances[@]}; do
    if [[ `echo $item | grep 'compute.amazonaws.com'` ]]; then
        printf "$item\n"
    else
        printf "$item "
    fi
done
```
 
- zshの設定にこんな感じのものを書きます(zshrc)

```
function get_ec2_list() {
    local get_list
    get_list="/home/hoge/get-ec2-list.sh"
    BUFFER=$(eval $get_list | peco  | awk '{print $2}')
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N get_ec2_list
bindkey '^v' get_ec2_list
```

こんな感じのものをつくると

> QUERY>  
> web  ec2-192-0-2-1.region.compute.amazonaws.com  
> db   ec2-192-0-2-2.region.compute.amazonaws.com  
> app1 ec2-192-0-2-3.region.compute.amazonaws.com  
> app2 ec2-192-0-2-4.region.compute.amazonaws.com  

こんな感じでEC2のNameを利用してPublic DNSを絞り込める。  
awkを利用して、選択したら  
Public Name(ec2-192-0-2-1.region.compute.amazonaws.com の方)だけが選択される。  
便利。便利だけど落書きレベルなのでGoで完結できるようにした方が良い。  
