---
layout: post
title: "特定のRoleのEIPが付与されているEC2がTerminateされた時に新しく起動したEC2に浮いたEIPを付与させるスクリプト"
published: true
date: "2016-07-08T13:32:00+09:00"
comments: true


---

件の通り

<blockquote class="twitter-tweet" data-lang="en"><p lang="ja" dir="ltr"><a href="https://twitter.com/kenjiskywalker">@kenjiskywalker</a> そんな仕組みあるの？</p>&mdash; そのっつ (Naotoshi Seo) (@sonots) <a href="https://twitter.com/sonots/status/751219867785711616">July 8, 2016</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet" data-lang="en"><p lang="ja" dir="ltr"><a href="https://twitter.com/kenjiskywalker">@kenjiskywalker</a> クレクレ</p>&mdash; そのっつ (Naotoshi Seo) (@sonots) <a href="https://twitter.com/sonots/status/751220071335235585">July 8, 2016</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

今見直したら結構ひどい感じだったけど一旦公開しておく。  
AWS SDK for Rubyを利用してもいいし、これぐらいならgoで書いても良いスね。  

### 仕組み

- `Role`  - web, db, app, etc...
- `Stage` - development, staging, production, etc...

`EC2`のインスタンスそれぞれに[タグ](http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/Using_Tags.html)の設定を入れている。  
それぞれのインスタンスは[AutoScalingGroup](http://docs.aws.amazon.com/ja_jp/AutoScaling/latest/DeveloperGuide/WhatIsAutoScaling.html)管理下にあり、  
上記タグもそれぞれのAutoScalingGroupにてインスタンス起動時に付与するようになっている。

#### 起動時に浮いたEIPをアサインさせたい

Ref: [Qiita:AmazonLinuxのcloud-initについての調査メモ](http://qiita.com/toshihirock/items/81d6612511f0d1f5db77)  

`cloud-init`のいい感じのオフィシャルドキュメントってどこにあるんだ...

- /var/lib/cloud/scripts/per-boot/004_assign-elastic-ip.rb

```rb
#!/usr/bin/env ruby

#
# 基本的に 各Role に EIP を付与するインスタンスは 2台 毎
# 
#

INSTANCEID  = `curl -s http://169.254.169.254/latest/meta-data/instance-id/`

REGION      = 'ap-northeast-1'
ROLE        = `aws --region #{REGION} ec2 describe-instances \
                 --instance-ids #{INSTANCEID} \
                 --output text \
                 --query 'Reservations[].Instances[].Tags[?Key==\`Role\`].[Value]' \
                 `.chomp
STAGE       = `aws --region #{REGION} ec2 describe-instances \
                 --instance-ids #{INSTANCEID} \
                 --output text \
                 --query 'Reservations[].Instances[].Tags[?Key==\`Stage\`].[Value]' \
                 `.chomp

# foo, bar以外はEIPの付与はないので一旦この条件を設定する
exit 0 unless ROLE == 'foo' || ROLE == 'bar'

# 浮いたEIPを入れる変数
elasticip_allocation_ids = []

# ROLE と STAGE 毎に保持している EIP は違う
# TODO: hash or json
case ROLE
when 'foo'
  if STAGE == 'development'
    elasticip_allocation_ids = ['eipalloc-XXXXXXXX', 'eipalloc-XXXXXXXX']
  elsif STAGE == 'staging'
    elasticip_allocation_ids = ['eipalloc-XXXXXXXX', 'eipalloc-XXXXXXXX']
  else
    exit 0
  end
when 'bar'
  if STAGE == 'production'
    elasticip_allocation_ids = ['eipalloc-XXXXXXXX']
  elsif STAGE == 'staging'
    elasticip_allocation_ids = ['eipalloc-XXXXXXXX']
  else
    exit 0
  end
when 'baz'
  if STAGE == 'production'
    elasticip_allocation_ids = ['eipalloc-XXXXXXXX']
  elsif STAGE == 'staging'
    elasticip_allocation_ids = ['eipalloc-XXXXXXXX']
  else
    exit 0
  end
else
  exit 0
end

elasticip_allocation_ids.each do |eip_id|
  # 対象のEIPにEC2が紐付いているか確認(浮いたEIPを探す)
  assigned_instance_id = `aws --region #{REGION} ec2 describe-addresses \
                            --allocation-ids #{eip_id} \
                            | jq '.Addresses[].InstanceId' \
                            `.chomp
  
  # 浮いたEIPがあれば付与する処理へ移る
  next unless assigned_instance_id == 'null'
  
  # EIPを付与する
  `aws --region #{REGION} ec2 associate-address \
     --allocation-id #{eip_id} \
     --instance-id #{INSTANCEID}`
  puts "COMPLETE: associate-address --allocation-id #{eip_id} --instance-id #{INSTANCEID}"
  exit 0
end

puts "CANNOT ASSOCIATE EIP to `hostname`"
exit 1
```

という感じで`/var/lib/cloud/scripts/per-boot/`配下にスクリプトを置いている。  
