---
layout: post
title: "EC2のStatus Checkの変異をSNSを通してPagerDutyからSlackへ通知させる"
published: true
date: "2016-07-12T11:44:00+09:00"
comments: true


---

EC2がちょくちょくStatus ChecksがコケてTerminateされていたので  
CloudWatchで見ているStatus Checkの値の変異を見て  
SNSに通知をさせている。
  
`SNS <-> PagerDuty <-> Slack`
  
#### 参考URL
  
- [インスタンスのステータスチェック](http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/monitoring-system-instance-status-check.html)
- [AWS CloudWatch Integration Guide:PagerDuty](https://www.pagerduty.com/docs/guides/aws-cloudwatch-integration-guide/)
- [Slack Integration Guide:PagerDuty](https://www.pagerduty.com/docs/guides/slack-integration-guide/)

  
一番良いのはEC2が立ち上がってきた時に自分自身に下記設定を導入し  
自分が消える時に設定を削除するのが好ましいが、所々事情があり  
下記のようなスクリプトを特定のEC2で回している。

```rb
#!/usr/bin/env ruby

region = 'REGION'

# インスタンスID一覧を取得する ( --max-items XXX # インスタンス数次第 )
instance_ids = `aws --region #{region} ec2 describe-instances \
                    --max-items XXX \
                    --filters Name=tag-key,Values=Name \
                    | jq -r '.Reservations[].Instances[].InstanceId'
                    `

# CloudWatchでStatusCheckFailed_Checkが設定されているインスタンスID一覧 ( --max-items XXX # インスタンス数次第 )
checked_instance_ids = `aws --region #{region} cloudwatch describe-alarms \
                            --max-items XXX \
                            | jq -r '.MetricAlarms[].AlarmName' \
                            | grep 'StatusCheckFailed_Check' \
                            | cut -f 1 -d ' '
                            `

# 改行で要素を分割
instance_ids = instance_ids.split("\n")
checked_instance_ids = checked_instance_ids.split("\n")

# インスタンス一覧にあってCloudWatch側にない監視追加対象のインスタンスID一覧を抽出
new_instance_ids = instance_ids - checked_instance_ids

# CloudWatch側にあってインスタンス一覧にない削除対象のインスタンスID一覧を抽出
deleted_instance_ids = checked_instance_ids - instance_ids

# 監視追加対象のインスタンスID一覧が空でなければCloudWatchに追加していく
unless new_instance_ids.empty?
  new_instance_ids.each do |instance_id|

    # StageというKeyのタグで本番かそれ以外を分けている
    stage = `aws --region #{region} ec2 describe-instances \
                 --instance-ids #{instance_id} \
                 --query 'Reservations[].Instances[].Tags[?Key==\`Stage\`].Value' \
                 --output text
                 `.chomp

    # 本番の場合は通知先が違うのでSNSの向き先を変える
    if stage == 'production'
      sns_topic = 'PRODUCTION_SNS_TOPIC'
    else
      sns_topic = 'OTHER_SNS_TOPIC'
    end

    # MAIN: ここで設定を追加する
    `aws --region #{region} cloudwatch put-metric-alarm \
         --alarm-name "#{instance_id} StatusCheckFailed_Check" \
         --metric-name StatusCheckFailed \
         --namespace AWS/EC2 \
         --statistic Maximum \
         --dimensions Name=InstanceId,Value=#{instance_id} \
         --period 60 \
         --unit Count \
         --evaluation-periods 1 \
         --threshold 0 \
         --comparison-operator GreaterThanThreshold \
         --ok-actions #{sns_topic} \
         --alarm-actions #{sns_topic} \
         --insufficient-data-actions #{sns_topic}
         `

    puts "#{instance_id} StatusCheckFailed_Check is created"
  end
end

# 削除対象のインスタンスID一覧が空でなければ設定を削除していく
unless deleted_instance_ids.empty?
  deleted_instance_ids.each do |instance_id|

    # MAIN: ここで設定を削除する
    `aws --region #{region} cloudwatch delete-alarms \
         --alarm-names "#{instance_id} StatusCheckFailed_Check"`

    puts "#{instance_id} StatusCheckFailed_Check is deleted"
  end
end
```

こんな感じでやってる。
