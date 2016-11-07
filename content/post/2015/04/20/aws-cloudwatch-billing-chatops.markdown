---
layout: post
title: "AWSのCloudWatchで取得できるBillingの情報を毎日Slackに通知させて費用を常に把握する"
published: true
date: "2015-04-20T19:03:00+09:00"
comments: true


---

> DevOpsManの様子

![](http://i.gyazo.com/676b021a544cf4c8cb33ef8eaa829e0c.png)

AWSの利用金額は毎日知りたい。  
そこでSlackに昨日までの利用金額(月ごとにリセットされる)をSlackに通知するようにした。  
aws-sdkとかは使わずにシンプルに[aws-cli](http://aws.amazon.com/jp/cli/)と[jq](http://stedolan.github.io/jq/)とcurlだけでやるようにしている。  

```rb
#!/usr/bin/env ruby

require 'date'

# 今日の日付
d = Time.now

# 昨日の 00:00:00 ~ 23:59:59 の間のデータを利用して
start_time = DateTime.new(d.year, d.month, d.day) - 1
end_time = DateTime.new(d.year, d.month, d.day, 23, 59, 59) - 1

# 一日分の Sum 値を使って
period = '86400'

# CloudWatchの値を取得してきて
strings = "昨日までのAWSの利用費(月ごと)になります\n"
strings << "```\n"

# Billingのデータを持ってくる
num = `aws cloudwatch --region us-east-1 get-metric-statistics \
           --namespace 'AWS/Billing' \
           --dimensions "Name=Currency,Value=USD" \
           --metric-name EstimatedCharges 
           --start-time #{start_time} \
           --end-time #{end_time} \
           --period #{period} --statistics 'Sum' \
           | jq '.Datapoints[].Sum'`

strings << "EstimatedCharges : $#{num}"
strings << "```\n"
strings << 'ご確認をよろしくお願いいたします'

# DevOpsManに伝える
`curl -s https://slack.com/api/chat.postMessage -X POST \
  -d 'channel=#CHANNEL' \
  -d 'text= #{strings}'
  -d 'username=USERNAME' \
  -d 'icon_emoji=:ICON:' \
  -d 'token=xoxp-0000000000-0000000000-00000000000000000'`
```

定常業務はどんどんbotにやらせて、生産的な業務に注力してバリュー出していこ
